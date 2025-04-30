import AppKit

extension NSImage {
    
    @MainActor public static let theme = NSImageTheme()
}

public class NSImageTheme {
    
    public let laserPointerCursor = Bundle.module.image(forResource:  "laser-pointer-cursor")!
}
