import MetalKit

@MainActor
protocol GlassBoardViewDelegate : AnyObject {
    
    func didKeyUp()
}

class GlassBoardView: MTKView {

    weak var uiDelegate: GlassBoardViewDelegate?
    
    override var acceptsFirstResponder: Bool { true }
    
    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        self.colorPixelFormat = .bgra8Unorm
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
        self.delegate = self
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.keyCode == 53 && event.type == .keyDown {
            uiDelegate?.didKeyUp()
            return true
        }
        return true
    }
    
    override func viewDidMoveToWindow() {
        print("# viewDidMoveToWindow")
    }
}

extension GlassBoardView: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("# drawableSizeWillChange")
    }

    func draw(in view: MTKView) {
        print("# draw")
    }
}
