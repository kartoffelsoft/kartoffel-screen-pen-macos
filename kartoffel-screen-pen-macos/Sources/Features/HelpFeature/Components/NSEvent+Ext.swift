import AppKit

extension NSEvent.ModifierFlags {
    
    var symbolicDescription: String {
        var symbols: [String] = []
        if contains(.command) { symbols.append("⌘") }
        if contains(.option) { symbols.append("⌥") }
        if contains(.shift) { symbols.append("⇧") }
        if contains(.control) { symbols.append("⌃") }
        return symbols.joined()
    }
}
