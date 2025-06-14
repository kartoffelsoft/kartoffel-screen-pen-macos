import AppKit

extension NSImage {
    
    @MainActor public static let theme = NSImageTheme()
    
    public func withTintColor(_ color: NSColor) -> NSImage? {
        guard let image = self.copy() as? NSImage else { return nil }

        image.lockFocus()
        color.set()
        NSRect(origin: .zero, size: image.size).fill(using: .sourceIn)
        image.unlockFocus()

        return image
    }
}

public class NSImageTheme {

    public let appIcon = Bundle.module.image(forResource: "app-icon")!
    
    public let laserPointerCursor = Bundle.module.image(forResource: "laser-pointer-cursor")!
    public let penCursor = Bundle.module.image(forResource: "pen-cursor")!
}
