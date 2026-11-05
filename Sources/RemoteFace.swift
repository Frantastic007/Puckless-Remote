import AppKit
import ServiceManagement
import SwiftUI

/// Turns rotation of the ring into relative volume or bass steps, like the physical dial.
final class DialModel: ObservableObject {
    private static let degreesPerStep = 15.0
    private static let scrollPerStep = 30.0
    // The physical dial also falls back to volume after 15 seconds.
    private static let bassTimeout: TimeInterval = 15

    @Published private(set) var angle = 0.0
    @Published var bassMode = false {
        didSet { armBassTimeout() }
    }

    private let controller: SpeakerController
    private var rotationBuffer = 0.0
    private var scrollBuffer = 0.0
    private var bassTimer: DispatchWorkItem?

    init(controller: SpeakerController) {
        self.controller = controller
    }

    func rotate(by degrees: Double) {
        angle += degrees
        rotationBuffer += degrees
        while abs(rotationBuffer) >= Self.degreesPerStep {
            let up = rotationBuffer > 0
            rotationBuffer -= up ? Self.degreesPerStep : -Self.degreesPerStep
            step(up: up)
        }
    }

    func scroll(_ event: NSEvent) {
        // Momentum would keep changing the volume after the fingers have left the trackpad.
        guard event.momentumPhase.isEmpty else { return }
        let direction = event.isDirectionInvertedFromDevice ? -1.0 : 1.0
        let threshold = event.hasPreciseScrollingDeltas ? Self.scrollPerStep : 1.0
        scrollBuffer += event.scrollingDeltaY * direction
        if abs(scrollBuffer) >= threshold {
            let up = scrollBuffer > 0
            scrollBuffer = 0
            angle += up ? Self.degreesPerStep : -Self.degreesPerStep
            step(up: up)
        }
    }

    func step(up: Bool) {
        if bassMode {
            controller.send(up ? .bassUp : .bassDown)
            armBassTimeout()
        } else {
            controller.send(up ? .volumeUp : .volumeDown)
        }
    }

    private func armBassTimeout() {
        bassTimer?.cancel()
        guard bassMode else { return }
        let item = DispatchWorkItem { [weak self] in self?.bassMode = false }
        bassTimer = item
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.bassTimeout, execute: item)
    }
}

/// The area of the ring around the knob, so dragging only starts on the ring.
private struct RingShape: Shape {
    let inset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path(ellipseIn: rect)
        path.addEllipse(in: rect.insetBy(dx: inset, dy: inset))
        return path
    }
}

struct RemoteFace: View {
    static let diameter: CGFloat = 360
    private static let ringWidth: CGFloat = 44

    @ObservedObject var controller: SpeakerController
    @ObservedObject var dial: DialModel
    let onQuit: () -> Void

    @State private var lastDragAngle: Double?
    @State private var showSettings: Bool
    @State private var confirmPairing = false
    @State private var autostart = SMAppService.mainApp.status == .enabled
    @State private var autostartError: String?

    init(controller: SpeakerController, dial: DialModel, onQuit: @escaping () -> Void, showSettings: Bool = false) {
        self.controller = controller
        self.dial = dial
        self.onQuit = onQuit
        _showSettings = State(initialValue: showSettings)
    }

    var body: some View {
        ZStack {
            ring
            knob
            if showSettings { settingsFace } else { controlFace }
        }
        .frame(width: Self.diameter, height: Self.diameter)
        .coordinateSpace(name: "dial")
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
    }

    private func t(_ german: String, _ english: String) -> String {
        controller.language.text(german, english)
    }

    // MARK: - Ring and knob

    private var ring: some View {
        ZStack {
            Circle()
                .fill(statusColor)
                .animation(.easeInOut(duration: 0.25), value: controller.state)
            ForEach(0..<24, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(0.75))
                    .frame(width: 3, height: 12)
                    .offset(y: -(Self.diameter - Self.ringWidth) / 2)
                    .rotationEffect(.degrees(Double(index) * 15 + dial.angle))
            }
        }
        .contentShape(RingShape(inset: Self.ringWidth), eoFill: true)
        .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .named("dial"))
            .onChanged { value in
                let center = Self.diameter / 2
                let current = atan2(value.location.y - center, value.location.x - center) * 180 / .pi
                if let last = lastDragAngle {
                    var delta = current - last
                    if delta > 180 { delta -= 360 }
                    if delta < -180 { delta += 360 }
                    dial.rotate(by: delta)
                }
                lastDragAngle = current
            }
            .onEnded { _ in lastDragAngle = nil })
        .accessibilityLabel(t("Drehring", "Dial ring"))
    }

    private var knob: some View {
        Circle()
            .fill(LinearGradient(colors: [Color(white: 0.30), Color(white: 0.10)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(Circle().stroke(.black.opacity(0.5), lineWidth: 2))
            .padding(Self.ringWidth)
    }

    // MARK: - Control face

    private var controlFace: some View {
        ZStack {
            statusLine.offset(y: -112)
            modeSwitch.offset(y: -80)

            RepeatButton(symbol: "minus",
                         label: dial.bassMode ? t("Bass runter", "Bass down") : t("Leiser", "Volume down")) {
                dial.step(up: false)
            }
            .offset(x: -86, y: -16)
            faceButton("playpause.fill", label: t("Wiedergabe oder Pause", "Play or pause"), size: 64, font: 26) {
                controller.send(.playPause)
            }
            .offset(y: -16)
            RepeatButton(symbol: "plus",
                         label: dial.bassMode ? t("Bass rauf", "Bass up") : t("Lauter", "Volume up")) {
                dial.step(up: true)
            }
            .offset(x: 86, y: -16)

            faceButton("backward.fill", label: t("Zurück", "Previous"), size: 34, font: 13) {
                controller.send(.previous)
            }
            .offset(x: -46, y: 40)
            faceButton("forward.fill", label: t("Weiter", "Next"), size: 34, font: 13) {
                controller.send(.next)
            }
            .offset(x: 46, y: 40)

            inputs.offset(y: 78)

            HStack(spacing: 8) {
                faceButton("gearshape.fill", label: t("Einstellungen", "Settings"), size: 26, font: 12) {
                    showSettings = true
                }
                linkButton
                faceButton("power", label: t("Beenden", "Quit"), size: 26, font: 12, action: onQuit)
                    .help(t("App beenden", "Quit the app"))
            }
            .offset(y: 112)
        }
    }

    private var statusLine: some View {
        HStack(spacing: 6) {
            Circle().fill(statusColor).frame(width: 8, height: 8)
            Text(statusText).font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .frame(width: 170)
    }

    @ViewBuilder
    private var modeSwitch: some View {
        if let notice = controller.notice {
            Text(notice.text(controller.language))
                .font(.system(size: 10))
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(width: 190)
        } else {
            HStack(spacing: 0) {
                modeTab(t("Lautstärke", "Volume"), active: !dial.bassMode) { dial.bassMode = false }
                modeTab("Bass", active: dial.bassMode) { dial.bassMode = true }
            }
            .background(Capsule().fill(.white.opacity(0.12)))
            .frame(width: 170)
        }
    }

    private func modeTab(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: active ? .semibold : .regular))
                .frame(maxWidth: .infinity, minHeight: 24)
                .background(Capsule().fill(active ? Color(red: 0.95, green: 0.32, blue: 0.28) : .clear))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var inputs: some View {
        HStack(spacing: 6) {
            ForEach(Input.allCases) { input in
                let active = controller.input == input
                Button {
                    controller.send(input.command)
                } label: {
                    Text(input == .bluetooth ? "BT" : input.rawValue)
                        .font(.system(size: 11, weight: active ? .semibold : .regular))
                        .frame(width: 50, height: 22)
                        .background(Capsule().fill(active
                            ? Color(red: 0.95, green: 0.32, blue: 0.28)
                            : .white.opacity(0.12)))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(t("Eingang", "Input") + " \(input.rawValue)")
            }
        }
    }

    @ViewBuilder
    private var linkButton: some View {
        if controller.state == .idle {
            faceButton("antenna.radiowaves.left.and.right", label: t("Verbinden", "Connect"), size: 26, font: 11) {
                controller.connect()
            }
            .help(t("Mit dem Lautsprecher verbinden", "Connect to the speaker"))
        } else {
            faceButton("antenna.radiowaves.left.and.right.slash", label: t("Trennen", "Disconnect"),
                       size: 26, font: 11) {
                controller.disconnect()
            }
            .help(t("Gibt die Verbindung für die mitgelieferte Fernbedienung frei",
                    "Frees the connection for the supplied dial"))
        }
    }

    private func faceButton(_ symbol: String, label: String, size: CGFloat, font: CGFloat,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: font, weight: .semibold))
                .frame(width: size, height: size)
                .background(Circle().fill(.white.opacity(0.12)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Settings face

    private var settingsFace: some View {
        VStack(spacing: 8) {
            Text(t("Einstellungen", "Settings")).font(.system(size: 13, weight: .semibold))

            Picker(t("Sprache", "Language"), selection: $controller.language) {
                ForEach(Language.allCases) { Text($0.title).tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.segmented)

            Picker(t("Verbindung", "Connection"), selection: $controller.mode) {
                ForEach(ConnectionMode.allCases) { Text($0.title(controller.language)).tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.segmented)

            Text(controller.mode == .always
                 ? t("Reagiert sofort, blockiert die mitgelieferte Fernbedienung.",
                     "Responds instantly, blocks the supplied dial.")
                 : t("Erster Tastendruck dauert einige Sekunden.",
                     "The first press takes a few seconds."))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Toggle(t("Tastenkürzel", "Keyboard shortcuts"), isOn: $controller.hotkeysEnabled)
            Toggle(t("Beim Anmelden starten", "Start at login"),
                   isOn: Binding(get: { autostart }, set: setAutostart))
            if let autostartError {
                Text(autostartError).font(.system(size: 10)).foregroundStyle(.orange).lineLimit(2)
            }

            if confirmPairing {
                HStack {
                    Button(t("Koppeln", "Pair")) {
                        controller.send(.pairing)
                        confirmPairing = false
                    }
                    Button(t("Abbrechen", "Cancel")) { confirmPairing = false }
                }
            } else {
                Button(t("Kopplungsmodus …", "Pairing mode …")) { confirmPairing = true }
            }

            Button(t("Fertig", "Done")) {
                confirmPairing = false
                showSettings = false
            }
        }
        .font(.system(size: 12))
        .frame(width: 206)
    }

    private func setAutostart(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            autostartError = nil
        } catch {
            autostartError = error.localizedDescription
        }
        autostart = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Status

    private var statusColor: Color {
        Color(nsColor: controller.state.statusColor)
    }

    private var statusText: String {
        switch controller.state {
        case .connected: return t("Verbunden", "Connected")
        case .searching: return t("Suche …", "Searching …")
        case .connecting: return t("Verbinde …", "Connecting …")
        case .idle: return t("Getrennt", "Disconnected")
        case .bluetoothOff: return t("Bluetooth aus", "Bluetooth off")
        case .unauthorized: return t("Keine Berechtigung", "No permission")
        }
    }
}

/// Fires once on press, then repeats while held.
struct RepeatButton: View {
    // A press whose release never arrives must not run away with the volume.
    private static let maxRepeats = 25

    let symbol: String
    let label: String
    let action: () -> Void

    @State private var pressed = false
    @State private var timer: Timer?
    @State private var delay: DispatchWorkItem?

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .bold))
            .frame(width: 44, height: 44)
            .background(Circle().fill(pressed ? Color.white.opacity(0.35) : Color.white.opacity(0.12)))
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in if !pressed { start() } }
                .onEnded { _ in stop() })
            .onDisappear(perform: stop)
            .accessibilityElement()
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default, action)
    }

    private func start() {
        pressed = true
        action()
        let item = DispatchWorkItem {
            var count = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { t in
                count += 1
                if count > Self.maxRepeats {
                    t.invalidate()
                    return
                }
                action()
            }
        }
        delay = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: item)
    }

    private func stop() {
        pressed = false
        delay?.cancel()
        delay = nil
        timer?.invalidate()
        timer = nil
    }
}
