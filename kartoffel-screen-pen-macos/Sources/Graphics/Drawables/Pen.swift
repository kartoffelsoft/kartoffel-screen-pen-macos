import Foundation
import MTLRenderer

public class Pen: AnyDrawable {
    
    public override init() {
    }

    deinit {
    }

    public override func start(at point: CGPoint) {
        path.removeAll()
        path.append(point)
        minX = point.x
        minY = point.y
        maxX = point.x
        maxY = point.y
    }

    public override func add(point: CGPoint) {
        path.append(point)
        minX = min(minX, point.x)
        minY = min(minY, point.y)
        maxX = max(maxX, point.x)
        maxY = max(maxY, point.y)
    }

    public override func draw(with renderer: MTLRenderer) {
//        if(_path.size() < 2)
//        {
//            return;
//        }
//        
//        builder.push_clip_rect({_min_x - 3,
//                                _min_y - 3,
//                                _max_x - _min_x + 6,
//                                _max_y - _min_y + 6});
//        
//        builder.add_polyline(_path, {0xFF, 0xFF, 0x00, 0xFF}, 6);
//        
//        builder.pop_clip_rect();
    }
}
