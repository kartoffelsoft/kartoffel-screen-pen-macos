import AppKit

extension NSImage {
    
    @MainActor public static let theme = NSImageTheme()
}

public class NSImageTheme {

    public let appIcon = Bundle.module.image(forResource: "app-icon")!
    
    public let laserPointerCursor = Bundle.module.image(forResource: "laser-pointer-cursor")!
    public let penCursor = Bundle.module.image(forResource: "pen-cursor")!
}
