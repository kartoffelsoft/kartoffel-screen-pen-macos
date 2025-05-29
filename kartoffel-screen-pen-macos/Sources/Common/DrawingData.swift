import Foundation

public struct DrawingData: Equatable {
    
    public var drawingTool: DrawingTool
    public var minX: CGFloat
    public var minY: CGFloat
    public var maxX: CGFloat
    public var maxY: CGFloat
    public var path: [CGPoint]
    public var rawPath: [CGPoint]
    
    public init() {
        self.drawingTool = .none
        self.minX = CGFloat.greatestFiniteMagnitude
        self.minY = CGFloat.greatestFiniteMagnitude
        self.maxX = -CGFloat.greatestFiniteMagnitude
        self.maxY = -CGFloat.greatestFiniteMagnitude
        self.path = []
        self.rawPath = []
    }
    
    public mutating func add(point: CGPoint) {
        minX = min(minX, point.x)
        minY = min(minY, point.y)
        maxX = max(maxX, point.x)
        maxY = max(maxY, point.y)

        rawPath.append(point)

        guard rawPath.count >= 4 else { return }

        let segment = interpolateCatmullRomSegment(points: Array(rawPath.suffix(4)))
        path.append(contentsOf: segment)
    }
    
    private func interpolateCatmullRomSegment(points: [CGPoint]) -> [CGPoint] {
        guard points.count == 4 else { return [] }

        var result: [CGPoint] = []

        let p0 = points[0], p1 = points[1], p2 = points[2], p3 = points[3]

        for i in 0..<8 {
            let t = CGFloat(i) / CGFloat(8)
            result.append(catmullRom(t: t, p0: p0, p1: p1, p2: p2, p3: p3))
        }

        return result
    }
    
    private func catmullRom(
        t: CGFloat,
        p0: CGPoint,
        p1: CGPoint,
        p2: CGPoint,
        p3: CGPoint
    ) -> CGPoint {
        let t2 = t * t
        let t3 = t2 * t
        
        let x = 0.5 * (
            2.0 * p1.x +
            (p2.x - p0.x) * t +
            (2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 +
            ( -p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3
        )
        
        let y = 0.5 * (
            2.0 * p1.y +
            (p2.y - p0.y) * t +
            (2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 +
            ( -p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3
        )
        
        return CGPoint(x: x, y: y)
    }
}
