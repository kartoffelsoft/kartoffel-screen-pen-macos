import Foundation
import MTLRenderer

public protocol Drawable {
    
    var minX: CGFloat { get set }
    var minY: CGFloat { get set }
    var maxX: CGFloat { get set }
    var maxY: CGFloat { get set }
    var path: [CGPoint] { get set }
    
    func start(at point: CGPoint)
    func add(point: CGPoint)
    func draw(with renderer: MTLRenderer)
}

public class AnyDrawable: Drawable, Equatable {
    
    public var minX: CGFloat = 0.0
    public var minY: CGFloat = 0.0
    public var maxX: CGFloat = 0.0
    public var maxY: CGFloat = 0.0
    public var path: [CGPoint] = []
    
    public func start(at point: CGPoint) {
    }
    
    public func add(point: CGPoint) {
    }
    
    public func draw(with renderer: MTLRenderer) {
    }
    
    public static func == (lhs: AnyDrawable, rhs: AnyDrawable) -> Bool {
        return lhs.minX == rhs.minX &&
            lhs.minY == rhs.minY &&
            lhs.maxX == rhs.maxX &&
            lhs.maxY == rhs.maxY &&
            lhs.path == rhs.path
    }
}
