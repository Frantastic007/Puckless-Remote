import AppKit
import Combine
import CoreBluetooth
import Foundation

// Factory reset (8300) is deliberately not part of this app.
enum Command: String {
    case bassUp, bassDown, volumeUp, volumeDown, playPause, next, previous
    case inputBluetooth, inputAux, inputUSB, pairing

    var bytes: [UInt8] {
        switch self {
        case .bassUp: return [0x80, 0x00]
        case .bassDown: return [0x80, 0x01]
        case .volumeUp: return [0x80, 0x02]
        case .volumeDown: return [0x80, 0x03]
        case .playPause: return [0x80, 0x04]
        case .next: return [0x80, 0x05]
        case .previous: return [0x80, 0x06]
        case .inputBluetooth: return [0x81, 0x01]
        case .inputAux: return [0x81, 0x02]
        case .inputUSB: return [0x81, 0x03]
        case .pairing: return [0x82, 0x00]
        }
    }
}

enum Input: String, CaseIterable, Identifiable {
    case bluetooth = "Bluetooth", aux = "AUX", usb = "USB"
    var id: String { rawValue }
    var command: Command {
        switch self {
        case .bluetooth: return .inputBluetooth
        case .aux: return .inputAux
        case .usb: return .inputUSB
        }
    }
}

enum ConnectionMode: String, CaseIterable, Identifiable {
    case always = "Dauerhaft", onDemand = "Bei Bedarf"
    var id: String { rawValue }
}

enum LinkState: Equatable {
    case bluetoothOff, unauthorized, idle, searching, connecting, connected

    /// Shared by the menu bar icon and the open remote, so both always show the same color.
    var statusColor: NSColor {
        switch self {
        case .connected: return .systemGreen
        case .searching, .connecting: return .systemOrange
        case .idle, .bluetoothOff, .unauthorized: return .systemRed
        }
    }
}

enum Log {
    static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Logs/Puckless.log")
    private static let maxBytes = 1_000_000
    private static var bytesWritten = 0
    private static let handle: FileHandle? = {
        let manager = FileManager.default
        try? manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let ownerOnly: [FileAttributeKey: Any] = [.posixPermissions: 0o600]
        manager.createFile(atPath: url.path, contents: nil, attributes: ownerOnly)
        // createFile keeps the old permissions when the file already exists.
        try? manager.setAttributes(ownerOnly, ofItemAtPath: url.path)
        return try? FileHandle(forWritingTo: url)
    }()
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()
    static func write(_ message: String) {
        guard let handle else { return }
        // A chatty or hostile device must not be able to fill the disk.
        if bytesWritten >= maxBytes {
            try? handle.truncate(atOffset: 0)
            bytesWritten = 0
            append("Log limit reached, started over", to: handle)
        }
        append(message, to: handle)
    }
    private static func append(_ message: String, to handle: FileHandle) {
        let line = Data("\(formatter.string(from: Date())) \(message)\n".utf8)
        try? handle.write(contentsOf: line)
        bytesWritten += line.count
    }
}

final class SpeakerController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private static let serviceUUID = CBUUID(string: "0000fdc2-0000-1000-8000-00805f9b34fb")
    private static let commandUUID = CBUUID(string: "c2e758b9-0e78-41e0-b0cb-98a593193fc5")
    private static let responseUUID = CBUUID(string: "b84ac9c6-29c5-46d4-bba1-9d534784330f")

    private static let scanTimeout: TimeInterval = 15
    private static let connectTimeout: TimeInterval = 10
    private static let commandLifetime: TimeInterval = 8
    private static let idleDisconnect: TimeInterval = 30
    private static let maxPending = 5
    private static let boundSpeakerKey = "boundSpeaker"

    @Published private(set) var state: LinkState = .idle
    @Published private(set) var input: Input?
    @Published private(set) var notice: Notice?
    /// The speaker this Mac is bound to. Other devices offering the same service are ignored.
    @Published private(set) var boundSpeaker: UUID?
    @Published var language: Language {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "language") }
    }
    @Published var mode: ConnectionMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: "connectionMode")
            paused = false
            demandActive = state == .connected
            armIdleTimer()
            evaluate()
        }
    }
    @Published var hotkeysEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hotkeysEnabled, forKey: "hotkeysEnabled")
            applyHotkeys()
        }
    }

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var commandChar: CBCharacteristic?
    private var pending: [(command: Command, created: Date)] = []
    private var watchdog: DispatchWorkItem?
    private var idleTimer: DispatchWorkItem?
    private var paused = false
    private var demandActive = false
    private var sleeping = false
    private var connectedAt: Date?
    private var handshakeAnswered = false
    private var ignoredDeviceLogged = false

    private var wanted: Bool {
        if sleeping || paused { return false }
        return mode == .always || demandActive
    }

    /// `connect: false` is for rendering previews: it leaves Bluetooth, the shortcuts and the log untouched.
    init(connect: Bool = true) {
        let defaults = UserDefaults.standard
        mode = ConnectionMode(rawValue: defaults.string(forKey: "connectionMode") ?? "") ?? .always
        hotkeysEnabled = defaults.object(forKey: "hotkeysEnabled") as? Bool ?? true
        language = Language(rawValue: defaults.string(forKey: "language") ?? "") ?? .systemDefault
        boundSpeaker = defaults.string(forKey: Self.boundSpeakerKey).flatMap(UUID.init(uuidString:))
        super.init()
        guard connect else { return }
        Log.write("App started, mode \(mode.rawValue)")
        central = CBCentralManager(delegate: self, queue: .main)

        Hotkeys.shared.handler = { [weak self] in self?.send($0) }
        applyHotkeys()

        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            Log.write("Mac going to sleep")
            self.sleeping = true
            self.teardown()
        }
        center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            Log.write("Mac woke up")
            self.sleeping = false
            self.evaluate(after: 2)
        }
    }

    // MARK: - Public actions

    func send(_ command: Command) {
        paused = false
        if mode == .onDemand {
            demandActive = true
            armIdleTimer()
        }
        if state == .connected {
            write(command)
            return
        }
        // Play/pause is a toggle: replaying several presses at once would only make playback stutter.
        if command == .playPause { pending.removeAll { $0.command == .playPause } }
        if pending.count >= Self.maxPending { pending.removeFirst() }
        pending.append((command, Date()))
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.commandLifetime + 0.1) { [weak self] in
            self?.expirePending()
        }
        evaluate()
    }

    func connect() {
        paused = false
        if mode == .onDemand {
            demandActive = true
            armIdleTimer()
        }
        evaluate()
    }

    /// Frees the single BLE slot so the supplied dial can connect again.
    func disconnect() {
        paused = true
        demandActive = false
        idleTimer?.cancel()
        pending.removeAll()
        Log.write("Disconnected by user")
        teardown()
    }

    /// Lets the app bind to the next speaker it finds, for example after replacing the speaker.
    func forgetSpeaker() {
        boundSpeaker = nil
        UserDefaults.standard.removeObject(forKey: Self.boundSpeakerKey)
        Log.write("Speaker binding removed")
        teardown()
        evaluate(after: 1)
    }

    // MARK: - Connection flow

    private func evaluate(after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.evaluate() }
    }

    private func evaluate() {
        guard central.state == .poweredOn else { return }
        if wanted {
            if state == .idle { startSearch() }
        } else if state != .idle {
            teardown()
        }
    }

    private func startSearch() {
        state = .searching
        ignoredDeviceLogged = false
        Log.write("Searching")
        central.scanForPeripherals(withServices: [Self.serviceUUID])
        armWatchdog(Self.scanTimeout) { [weak self] in
            guard let self else { return }
            Log.write("Speaker not found within \(Int(Self.scanTimeout))s")
            self.notice = .speakerNotFound
            if self.mode == .onDemand {
                self.demandActive = false
                self.pending.removeAll()
                self.teardown()
            }
        }
    }

    private func teardown() {
        watchdog?.cancel()
        central.stopScan()
        if let peripheral { central.cancelPeripheralConnection(peripheral) }
        resetLink()
        state = central.state == .poweredOn ? .idle : state
    }

    private func resetLink() {
        if let connectedAt {
            Log.write("Connection ended after \(Int(Date().timeIntervalSince(connectedAt)))s")
        }
        connectedAt = nil
        peripheral = nil
        commandChar = nil
        input = nil
        handshakeAnswered = false
    }

    private func retry() {
        teardown()
        evaluate(after: 2)
    }

    private func armWatchdog(_ seconds: TimeInterval, _ action: @escaping () -> Void) {
        watchdog?.cancel()
        let item = DispatchWorkItem(block: action)
        watchdog = item
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
    }

    private func armIdleTimer() {
        idleTimer?.cancel()
        guard mode == .onDemand else { return }
        let item = DispatchWorkItem { [weak self] in
            guard let self, self.demandActive else { return }
            Log.write("Idle, releasing connection")
            self.demandActive = false
            self.evaluate()
        }
        idleTimer = item
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.idleDisconnect, execute: item)
    }

    /// A queued volume step must not fire long after the click, so old commands are dropped.
    private func expirePending() {
        let cutoff = Date().addingTimeInterval(-Self.commandLifetime)
        let before = pending.count
        pending.removeAll { $0.created < cutoff }
        if pending.count < before {
            Log.write("Dropped \(before - pending.count) expired command(s)")
            notice = .commandDropped
        }
    }

    private func write(_ command: Command) {
        guard let peripheral, let commandChar else { return }
        Log.write("-> \(command.rawValue)")
        peripheral.writeValue(Data(command.bytes), for: commandChar, type: .withoutResponse)
    }

    private func writeRaw(_ bytes: [UInt8]) {
        guard let peripheral, let commandChar else { return }
        peripheral.writeValue(Data(bytes), for: commandChar, type: .withoutResponse)
    }

    private func applyHotkeys() {
        if hotkeysEnabled { Hotkeys.shared.enable() } else { Hotkeys.shared.disable() }
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Log.write("Bluetooth state \(central.state.rawValue)")
        switch central.state {
        case .poweredOn:
            state = .idle
            evaluate()
        case .unauthorized:
            resetLink()
            state = .unauthorized
        case .poweredOff, .unsupported, .resetting:
            watchdog?.cancel()
            resetLink()
            state = .bluetoothOff
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover found: CBPeripheral,
                        advertisementData: [String: Any], rssi: NSNumber) {
        guard state == .searching else { return }
        if let boundSpeaker, found.identifier != boundSpeaker {
            if !ignoredDeviceLogged {
                Log.write("Ignored a device other than the bound speaker")
                ignoredDeviceLogged = true
            }
            return
        }
        Log.write("Found speaker, RSSI \(rssi)")
        central.stopScan()
        peripheral = found
        found.delegate = self
        state = .connecting
        central.connect(found)
        armWatchdog(Self.connectTimeout) { [weak self] in
            Log.write("Connect or handshake timed out")
            self?.retry()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect connected: CBPeripheral) {
        guard connected === peripheral else { return }
        connected.discoverServices([Self.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect failed: CBPeripheral, error: Error?) {
        guard failed === peripheral else { return }
        Log.write("Connect failed: \(error?.localizedDescription ?? "unknown")")
        retry()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral lost: CBPeripheral, error: Error?) {
        guard lost === peripheral else { return }
        Log.write("Link lost: \(error?.localizedDescription ?? "no error")")
        watchdog?.cancel()
        resetLink()
        state = .idle
        evaluate(after: 2)
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = p.services?.first(where: { $0.uuid == Self.serviceUUID }) else {
            Log.write("Service missing: \(error?.localizedDescription ?? "")")
            retry()
            return
        }
        p.discoverCharacteristics([Self.commandUUID, Self.responseUUID], for: service)
    }

    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let chars = service.characteristics ?? []
        guard let command = chars.first(where: { $0.uuid == Self.commandUUID }),
              let response = chars.first(where: { $0.uuid == Self.responseUUID }) else {
            Log.write("Characteristics missing")
            retry()
            return
        }
        commandChar = command
        p.setNotifyValue(true, for: response)
    }

    func peripheral(_ p: CBPeripheral, didUpdateNotificationStateFor c: CBCharacteristic, error: Error?) {
        if let error {
            Log.write("Notify failed: \(error.localizedDescription)")
            retry()
            return
        }
        writeRaw([0x84, 0x05])
    }

    func peripheral(_ p: CBPeripheral, didUpdateValueFor c: CBCharacteristic, error: Error?) {
        guard p === peripheral, c.uuid == Self.responseUUID, let data = c.value else { return }
        let value = data.map { String(format: "%02x", $0) }.joined()
        Log.write("<- \(value)")
        switch value {
        case "d40501":
            // Only once during the handshake, so a device can't trigger writes at will.
            guard state == .connecting, !handshakeAnswered else { return }
            handshakeAnswered = true
            writeRaw([0x84, 0x00])
        case "d40001":
            // The protocol doc also lists d40003, but this speaker does not send it.
            handshakeFinished()
        case "c101", "cf04":
            input = .bluetooth
        case "c102", "cf05":
            input = .aux
        case "c103", "cf06":
            input = .usb
        default:
            break
        }
    }

    private func handshakeFinished() {
        guard state == .connecting, handshakeAnswered, let speaker = peripheral else { return }
        watchdog?.cancel()
        state = .connected
        notice = nil
        connectedAt = Date()
        Log.write("Connected")
        // Bound only now, so a device that fails the handshake never becomes the bound speaker.
        if boundSpeaker == nil {
            boundSpeaker = speaker.identifier
            UserDefaults.standard.set(speaker.identifier.uuidString, forKey: Self.boundSpeakerKey)
            Log.write("Bound to this speaker")
        }
        let cutoff = Date().addingTimeInterval(-Self.commandLifetime)
        let ready = pending.filter { $0.created >= cutoff }
        pending.removeAll()
        ready.forEach { write($0.command) }
    }
}
