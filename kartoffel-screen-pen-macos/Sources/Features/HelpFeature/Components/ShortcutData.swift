import AppKit

struct ShortcutData: Equatable {
    
    let keyEquivalent: String
    let keyEquivalentModifiers: NSEvent.ModifierFlags
    let description: Description
}

extension ShortcutData {
    
    enum Description: Equatable {
        
        case text(String)
        case color(NSColor)
    }
}
