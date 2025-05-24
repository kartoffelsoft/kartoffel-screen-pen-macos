import MetalKit

class GlassBoardView: MTKView {

    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
        
        self.wantsLayer = true
        self.layer?.isOpaque = false
        self.layer?.backgroundColor = .clear
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidMoveToWindow() {
        print("# viewDidMoveToWindow")
    }
}
