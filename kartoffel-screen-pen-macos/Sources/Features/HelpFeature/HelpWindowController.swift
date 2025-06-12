import AppKit

public class HelpWindowController: NSWindowController {

    public convenience init() {
        self.init(window: NSWindow(
            contentRect: .init(x: 0, y: 0, width: 800, height: 460),
            styleMask: [ .closable, .titled, .fullSizeContentView ],
            backing: .buffered,
            defer: false
        ))
    }
    
    public override init(window: NSWindow?) {
        super.init(window: window)
        
        window?.titlebarAppearsTransparent = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.isReleasedWhenClosed = false
        window?.center()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
