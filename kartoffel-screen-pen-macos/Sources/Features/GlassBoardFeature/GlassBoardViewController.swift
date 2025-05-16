import Cocoa
import Combine
import ComposableArchitecture

import MTLRenderer

public class GlassBoardViewController: NSViewController {

    private let store: StoreOf<GlassBoard>
    private let viewStore: ViewStoreOf<GlassBoard>
    private var cancellables: Set<AnyCancellable> = []
    
    private let renderer: MTLRenderer
    private var cursor: NSCursor?
    
    private var mtkView: MTKView {
        return self.view as! MTKView
    }
    
    public init(store: StoreOf<GlassBoard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.renderer = .init(device: MTLCreateSystemDefaultDevice())
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        mtkView.delegate = self
        mtkView.enableSetNeedsDisplay = true
        
        setupConstraints()
        setupBindings()
    }

    public override func viewWillAppear() {
        super.viewWillAppear()
        self.view.setFrameOrigin(viewStore.frame.origin)
        self.view.setFrameSize(viewStore.frame.size)
        self.view.window?.setFrame(viewStore.frame, display: true)
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.makeKeyAndOrderFront(nil)
    }
    
    public override var representedObject: Any? {
        didSet {
        }
    }
    
    public override func loadView() {
        self.view = GlassBoardView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    }
    
    public override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 && event.type == .keyDown {
            viewStore.send(.delegate(.dismiss))
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        viewStore.send(.beginDraw(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }
    
    public override func mouseUp(with event: NSEvent) {
        viewStore.send(.endDraw(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }

    public override func mouseDragged(with event: NSEvent) {
        viewStore.send(.continueDraw(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }
    
    private func setupConstraints() {
    }
    
    private func setupBindings() {
        viewStore.publisher.drawings.sink { [weak self] drawings in
            guard let self = self else { return }
            self.mtkView.needsDisplay = true
        }
        .store(in: &self.cancellables)
    }
}

extension GlassBoardViewController: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("# drawableSizeWillChange")
    }

    public func draw(in view: MTKView) {
        guard let currentDrawable = self.mtkView.currentDrawable else { return }

        renderer.beginDraw(
            withSurfaceHandle: currentDrawable,
            width: self.view.bounds.size.width,
            height: self.view.bounds.size.height,
            scale: self.view.window?.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        )
        
        for drawing in viewStore.drawings {
            guard drawing.path.count >= 2 else { continue }
            
            self.renderer.pushClipRect(.init(
                x: drawing.minX,
                y: drawing.minY,
                width: drawing.maxX - drawing.minX + 6,
                height: drawing.maxY - drawing.minY + 6
            ))
            
            switch drawing.drawingTool {
            case let .pen(color):
                ()
                
            case .laserPointer:
                drawing.path.withUnsafeBufferPointer { buffer in
                    guard let baseAddress = buffer.baseAddress else { return }
                    self.renderer.addPolyline(
                        withPath: baseAddress,
                        count: drawing.path.count,
                        color: .blue,
                        thickness: 4.0
                    )
                }
            
            case .eraser:
                ()
            
            default: ()
            }
            
            self.renderer.popClipRect()
        }
        
        renderer.endDraw()
    }
}
