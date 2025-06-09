import AppKit

public enum DrawingTool: Equatable, Sendable {
    
    case pen(color: CGColor)
    case laserPointer(color: CGColor)
    case eraser
    case none
}

extension DrawingTool {
    
    public func with(color: CGColor) -> DrawingTool {
        switch self {
        case .pen:
            return .pen(color: color)
        case .laserPointer:
            return .laserPointer(color: color)
        default:
            return self
        }
    }
}
