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
        viewStore.send(.startDrawing(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }
    
    public override func mouseUp(with event: NSEvent) {
        viewStore.send(.endDrawing(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }

    public override func mouseDragged(with event: NSEvent) {
        viewStore.send(.continueDrawing(.init(
            x: event.locationInWindow.x,
            y: self.view.frame.size.height - event.locationInWindow.y
        )))
    }
    
    private func setupConstraints() {
    }
    
    private func setupBindings() {
        viewStore.publisher.drawings.sink { [weak self] data in
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
        print("# draw")
    }
}
