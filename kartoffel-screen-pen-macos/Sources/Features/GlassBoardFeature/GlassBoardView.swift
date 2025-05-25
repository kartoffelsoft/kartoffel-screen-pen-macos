import MetalKit

class GlassBoardView: MTKView {

    public var cursor: NSCursor?
    private var trackingArea: NSTrackingArea?
    
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
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }

        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [
                .mouseEnteredAndExited,
                .mouseMoved,
                .activeInKeyWindow,
                .inVisibleRect
            ],
            owner: self,
            userInfo: nil
        )
        
        self.addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        resetCursorRects()
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        resetCursorRects()
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        resetCursorRects()
    }
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        guard let cursor = self.cursor else { return }
        self.addCursorRect(self.bounds, cursor: cursor)
    }
}
