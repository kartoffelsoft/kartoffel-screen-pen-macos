import AppKit
import Carbon.HIToolbox.Events

extension NSEvent.ModifierFlags {
    
    var carbonModifierFlags: UInt32 {
        var flags: UInt32 = 0
        if contains(.shift)   { flags |= UInt32(shiftKey)   }
        if contains(.control) { flags |= UInt32(controlKey) }
        if contains(.option)  { flags |= UInt32(optionKey)  }
        if contains(.command) { flags |= UInt32(cmdKey)     }
        return flags
    }
}
