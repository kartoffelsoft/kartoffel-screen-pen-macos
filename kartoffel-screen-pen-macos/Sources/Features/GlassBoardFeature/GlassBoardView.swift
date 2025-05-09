import MetalKit

class GlassBoardView: MTKView {

    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        self.colorPixelFormat = .bgra8Unorm
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
    }
    
    override func viewDidMoveToWindow() {
        print("# viewDidMoveToWindow")
    }
}
