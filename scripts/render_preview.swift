// Renders the round remote to a PNG on a neutral background, without touching Bluetooth.
// Usage: render_preview <output.png> [settings] [de|en]
import AppKit
import SwiftUI

@main
enum RenderPreview {
    static func main() throws {
        _ = NSApplication.shared
        let controller = SpeakerController(connect: false)
        controller.language = CommandLine.arguments.contains("en") ? .en : .de
        let view = RemoteFace(controller: controller, dial: DialModel(controller: controller), onQuit: {},
                              showSettings: CommandLine.arguments.contains("settings"))
        let host = NSHostingView(rootView: view.padding(20).background(Color(white: 0.75)))
        let side = RemoteFace.diameter + 40
        host.frame = NSRect(x: 0, y: 0, width: side, height: side)

        let window = NSWindow(contentRect: host.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))

        guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { exit(1) }
        host.cacheDisplay(in: host.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
        try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    }
}
