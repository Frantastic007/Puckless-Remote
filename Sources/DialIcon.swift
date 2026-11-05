import AppKit

/// A round control dial: a graphite knob inside a coloured ring.
/// Shared by the menu bar icon and the app icon.
enum DialIcon {
    static func draw(in rect: NSRect, ringStart: NSColor, ringEnd: NSColor) {
        let size = rect.width
        NSGradient(starting: ringStart, ending: ringEnd)?
            .draw(in: NSBezierPath(ovalIn: rect), angle: -90)

        let knobRect = rect.insetBy(dx: size * 0.13, dy: size * 0.13)
        NSGradient(starting: NSColor(calibratedWhite: 0.34, alpha: 1),
                   ending: NSColor(calibratedWhite: 0.10, alpha: 1))?
            .draw(in: NSBezierPath(ovalIn: knobRect), angle: -90)

        // Pointer line from the knob's edge towards its centre, as on a rotary knob.
        let width = size * 0.08
        let outer = size * 0.31
        let inner = size * 0.08
        let pointer = NSBezierPath()
        pointer.lineWidth = width
        pointer.lineCapStyle = .round
        pointer.move(to: NSPoint(x: rect.midX, y: rect.midY + inner))
        pointer.line(to: NSPoint(x: rect.midX, y: rect.midY + outer))
        NSColor.white.setStroke()
        pointer.stroke()
    }

    /// Non-template, because macOS otherwise renders menu bar icons monochrome.
    static func menuBarImage(color: NSColor) -> NSImage {
        let image = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { rect in
            draw(in: rect.insetBy(dx: 0.5, dy: 0.5), ringStart: color, ringEnd: color)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = "Puckless"
        return image
    }
}
