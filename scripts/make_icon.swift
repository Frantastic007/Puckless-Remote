// Draws the 1024x1024 app icon. Usage: make_icon <output.png>
import AppKit

@main
struct MakeIcon {
    static func main() throws {
        let size = 1024
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
            samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
            bytesPerRow: 0, bitsPerPixel: 0),
            let context = NSGraphicsContext(bitmapImageRep: rep) else { exit(1) }

        NSGraphicsContext.current = context
        DialIcon.draw(in: NSRect(x: 62, y: 62, width: 900, height: 900),
                      ringColors: [
                          NSColor(calibratedRed: 0.19, green: 0.82, blue: 0.35, alpha: 1),  // green
                          NSColor(calibratedRed: 1.00, green: 0.80, blue: 0.10, alpha: 1),  // amber
                          NSColor(calibratedRed: 1.00, green: 0.55, blue: 0.10, alpha: 1),  // orange
                          NSColor(calibratedRed: 0.90, green: 0.10, blue: 0.45, alpha: 1),  // pink
                      ])
        NSGraphicsContext.current = nil

        guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
        try png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
    }
}
