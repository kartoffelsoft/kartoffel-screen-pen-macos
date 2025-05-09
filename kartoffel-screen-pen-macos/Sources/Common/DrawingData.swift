import Foundation

public struct DrawingData: Equatable {
    
    public var drawingTool: DrawingTool
    public var minX: CGFloat
    public var minY: CGFloat
    public var maxX: CGFloat
    public var maxY: CGFloat
    public var path: [CGPoint]
    
    public init() {
        self.drawingTool = .none
        self.minX = CGFloat.greatestFiniteMagnitude
        self.minY = CGFloat.greatestFiniteMagnitude
        self.maxX = -CGFloat.greatestFiniteMagnitude
        self.maxY = -CGFloat.greatestFiniteMagnitude
        self.path = []
    }
    
    public mutating func add(point: CGPoint) {
        minX = min(minX, point.x)
        minY = min(minY, point.y)
        maxX = max(maxX, point.x)
        maxY = max(maxY, point.y)
        path.append(point)
    }
}
