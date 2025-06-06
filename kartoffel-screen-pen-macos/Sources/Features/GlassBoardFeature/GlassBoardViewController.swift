import Cocoa
import Combine
import ComposableArchitecture
import MTLRenderer
import StyleGuide

public class GlassBoardViewController: NSViewController {

    private let store: StoreOf<GlassBoard>
    private let viewStore: ViewStoreOf<GlassBoard>
    private var cancellables: Set<AnyCancellable> = []
    
    private let renderer: MTLRenderer
    private var canvas: MTLTexture?
    
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

        setupBindings()
    }

    public override func viewWillAppear() {
        super.viewWillAppear()
        self.view.setFrameOrigin(.zero)
        self.view.setFrameSize(viewStore.frame.size)
        self.view.window?.setFrame(viewStore.frame, display: true)
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    public override var representedObject: Any? {
        didSet {
        }
    }
    
    public override func loadView() {
        self.view = GlassBoardView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    }

    private func setupBindings() {
        viewStore.publisher.frame.sink { [weak self] frame in
            guard let self = self else { return }
            self.view.setFrameOrigin(.zero)
            self.view.setFrameSize(frame.size)
            self.view.window?.setFrame(frame, display: true)
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.currentDrawingTool.sink { [weak self] tool in
            guard let self = self else { return }
            guard let view = self.view as? GlassBoardView else { return }
            
            switch tool {
            case .pen:
                let image = NSImage.theme.appIcon
                image.size = NSSize(width: 20, height: 20)
                view.cursor = NSCursor(image: image, hotSpot: NSPoint(x: 10, y: 10))
                view.resetCursorRects()
                break
                
            case .laserPointer:
                let image = NSImage.theme.laserPointerCursor
                image.size = NSSize(width: 20, height: 20)
                view.cursor = NSCursor(image: image, hotSpot: NSPoint(x: 10, y: 10))
                view.resetCursorRects()
                break
                
            case .eraser:
                break
                
            case .none:
                break
            }
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.drawings.sink { [weak self] drawings in
            guard let self = self else { return }
            guard let canvas = self.canvas else { return }
            guard let drawing = drawings.last else { return }
            
            let path = Array(drawing.path.suffix(9))
            guard path.count >= 2 else { return }
            
            renderer.beginDraw(
                onTexture: canvas,
                width: view.bounds.width,
                height: view.bounds.height,
                scale: self.view.window?.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
            )
            
            self.renderer.pushClipRect(.init(
                x: 0,
                y: 0,
                width: view.bounds.width,
                height: view.bounds.height,
            ))
            
            switch drawing.drawingTool {
            case let .pen(color):
                ()
                
            case .laserPointer:
                path.withUnsafeBufferPointer { buffer in
                    guard let baseAddress = buffer.baseAddress else { return }
                    self.renderer.addPolyline(
                        with: baseAddress,
                        count: path.count,
                        color: .blue,
                        thickness: 4.0
                    )
                }
                
            case .eraser:
                ()
                
            default: ()
            }
            
            self.renderer.popClipRect()
            
            renderer.endDraw()
            
            self.mtkView.needsDisplay = true
        }
        .store(in: &self.cancellables)
    }
    
    private func setupCanvas(with size: CGSize) {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false
        )
        desc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        canvas = mtkView.device?.makeTexture(descriptor: desc)
    }
}

extension GlassBoardViewController: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setupCanvas(with: size)
    }

    public func draw(in view: MTKView) {
        guard let currentDrawable = mtkView.currentDrawable else { return }
        
        renderer.beginDraw(
            onDrawable: currentDrawable,
            width: view.bounds.size.width,
            height: view.bounds.size.height,
            scale: view.window?.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        )

        renderer.endDraw()
    }
}
