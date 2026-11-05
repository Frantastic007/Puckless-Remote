import AppKit
import Combine
import SwiftUI

@main
enum PucklessMain {
    private static let delegate = AppDelegate()

    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = delegate
        app.run()
    }
}

/// Borderless panels refuse key status by default, which would disable the controls.
final class RoundPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = SpeakerController()
    private lazy var dial = DialModel(controller: controller)
    private var statusItem: NSStatusItem!
    private var panel: RoundPanel!
    private var monitors: [Any] = []
    private var stateSubscription: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePanel)

        let size = RemoteFace.diameter
        panel = RoundPanel(contentRect: NSRect(x: 0, y: 0, width: size, height: size),
                           styleMask: [.borderless, .nonactivatingPanel],
                           backing: .buffered, defer: true)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isReleasedWhenClosed = false

        stateSubscription = controller.$state.sink { [weak self] state in
            self?.statusItem.button?.image = DialIcon.menuBarImage(color: state.statusColor)
        }
    }

    @objc private func togglePanel() {
        if panel.isVisible { hidePanel() } else { showPanel() }
    }

    private func showPanel() {
        guard let buttonWindow = statusItem.button?.window else { return }
        let size = RemoteFace.diameter
        let anchor = buttonWindow.frame
        var origin = NSPoint(x: anchor.midX - size / 2, y: anchor.minY - size - 4)
        if let screen = buttonWindow.screen?.visibleFrame {
            origin.x = min(max(origin.x, screen.minX + 4), screen.maxX - size - 4)
        }
        panel.contentView = NSHostingView(rootView: RemoteFace(
            controller: controller, dial: dial, onQuit: { NSApp.terminate(nil) }))
        panel.setFrame(NSRect(origin: origin, size: NSSize(width: size, height: size)), display: true)
        panel.makeKeyAndOrderFront(nil)
        panel.invalidateShadow()
        addMonitors()
    }

    private func hidePanel() {
        monitors.forEach(NSEvent.removeMonitor)
        monitors.removeAll()
        panel.orderOut(nil)
        // Dropping the view lets a held button see onDisappear and stop repeating.
        panel.contentView = nil
    }

    private func addMonitors() {
        if let outside = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown], handler: { [weak self] _ in self?.hidePanel() }) {
            monitors.append(outside)
        }
        if let local = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .keyDown, .scrollWheel], handler: { [weak self] in self?.handle($0) }) {
            monitors.append(local)
        }
    }

    private func handle(_ event: NSEvent) -> NSEvent? {
        guard event.window === panel || event.type == .keyDown else { return event }
        switch event.type {
        case .keyDown where event.keyCode == 53:
            hidePanel()
            return nil
        case .leftMouseDown:
            let radius = RemoteFace.diameter / 2
            let dx = event.locationInWindow.x - radius
            let dy = event.locationInWindow.y - radius
            if dx * dx + dy * dy > radius * radius {
                hidePanel()
                return nil
            }
            return event
        case .scrollWheel:
            dial.scroll(event)
            return nil
        default:
            return event
        }
    }
}
