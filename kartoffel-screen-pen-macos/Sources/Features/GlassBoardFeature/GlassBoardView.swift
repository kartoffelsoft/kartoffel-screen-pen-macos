import MetalKit

class GlassBoardView: MTKView {

    override init(frame frameRect: CGRect, device: (any MTLDevice)?) {
        super.init(frame: frameRect, device: device)
        
        self.wantsLayer = true
        self.layer?.isOpaque = false

#if DEBUG
        self.layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.1).cgColor
#else
        self.layer?.backgroundColor = .clear
#endif
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidMoveToWindow() {
        print("# viewDidMoveToWindow")
    }
}
