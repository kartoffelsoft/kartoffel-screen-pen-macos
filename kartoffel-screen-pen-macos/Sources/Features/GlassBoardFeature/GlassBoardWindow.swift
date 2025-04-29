import Cocoa

public class GlassBoardWindow: NSWindow {
    
    public override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(contentRect: contentRect,
                   styleMask: .borderless,
                   backing: backing,
                   defer: flag)
        
        self.level = .popUpMenu
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = false
    }
    
    public override var canBecomeKey: Bool { true }
}
