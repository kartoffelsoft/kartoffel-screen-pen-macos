import AppKit

struct ShortcutData: Equatable {
    
    let keyEquivalent: String
    let keyEquivalentModifiers: NSEvent.ModifierFlags
    let description: String
}
