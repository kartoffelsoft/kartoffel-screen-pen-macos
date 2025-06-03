import AppKit

public struct HotKeyEntry: Equatable, Identifiable, Sendable {
    
    public let id: UInt32
    public var keyEquivalent: String
    public var keyEquivalentModifierMask: NSEvent.ModifierFlags

    public init(
        id: UInt32,
        keyEquivalent: String,
        keyEquivalentModifierMask: NSEvent.ModifierFlags
    ) {
        self.id = id
        self.keyEquivalent = keyEquivalent
        self.keyEquivalentModifierMask = keyEquivalentModifierMask
    }
}
