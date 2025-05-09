import AppKit

public enum DrawingTool: Equatable {
    
    case pen(color: NSColor)
    case laserPointer
    case eraser
    case none
}
