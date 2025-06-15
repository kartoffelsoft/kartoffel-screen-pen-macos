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
    private var cursor: MTLTexture?
    
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
        setupCursor()
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
        viewStore.publisher.drawingTool.sink { [weak self] tool in
            guard let self = self else { return }
            guard let cursor = cursor else { return }
            
            let width = 64
            let height = 64
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let imageByteCount = height * bytesPerRow
            
            var rawData = [UInt8](repeating: 0, count: imageByteCount)
            
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
                  let cgContext = CGContext(
                      data: &rawData,
                      width: width,
                      height: height,
                      bitsPerComponent: 8,
                      bytesPerRow: bytesPerRow,
                      space: colorSpace,
                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue |
                                  CGBitmapInfo.byteOrder32Little.rawValue
                  ) else { return }
            
            let cursorImage: NSImage?
            
            switch tool {
            case .pen:
                cursorImage = NSImage.theme.penCursor
            case .laserPointer:
                cursorImage = NSImage.theme.laserPointerCursor
            case .eraser:
                cursorImage = NSImage.theme.laserPointerCursor
            case .none:
                cursorImage = nil
            }

            if let cursorImage = cursorImage {
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current = NSGraphicsContext(cgContext: cgContext, flipped: false)
                cursorImage.draw(in: .init(x: 0, y: 0, width: width, height: height))
                NSGraphicsContext.restoreGraphicsState()
            }

            let region = MTLRegionMake2D(0, 0, width, height)
            cursor.replace(region: region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: bytesPerRow)
            
            self.mtkView.needsDisplay = true
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.frame.sink { [weak self] frame in
            guard let self = self else { return }
            self.view.setFrameOrigin(.zero)
            self.view.setFrameSize(frame.size)
            self.view.window?.setFrame(frame, display: true)
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.commandSignal.sink { [weak self] commandSignal in
            guard let command = commandSignal?.value else { return }
            guard let self = self else { return }
            guard let canvas = self.canvas else { return }
            
            if case .none = command { return }
            
            if case .refresh = command {
                self.mtkView.needsDisplay = true
                return
            }
            
            if case .clear = command {
                renderer.beginDraw(
                    onTexture: canvas,
                    loadAction: MTLLoadAction.clear,
                    width: view.bounds.width,
                    height: view.bounds.height,
                    scale: self.view.window?.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
                )
                renderer.endDraw()
                self.mtkView.needsDisplay = true
                return
            }
            
            if case .redraw = command {
                renderer.beginDraw(
                    onTexture: canvas,
                    loadAction: MTLLoadAction.clear,
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
                
                for drawing in viewStore.drawings {
                    guard drawing.path.count >= 2 else { continue }
                    if case let .pen(color) = drawing.drawingTool {
                        drawing.path.withUnsafeBufferPointer { buffer in
                            guard let baseAddress = buffer.baseAddress else { return }
                            self.renderer.addPolyline(
                                with: baseAddress,
                                count: drawing.path.count,
                                color: color,
                                thickness: 4.0
                            )
                        }
                    }
                }
                
                self.renderer.popClipRect()
                
                renderer.endDraw()
                self.mtkView.needsDisplay = true
                return
            }
            
            if case .draw = command {
                guard let drawing = viewStore.drawings.last else { return }

                let path = Array(drawing.path.suffix(9))
                guard path.count >= 2 else { return }

                switch drawing.drawingTool {
                case let .pen(color):
                    renderer.beginDraw(
                        onTexture: canvas,
                        loadAction: .load,
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
                    
                    path.withUnsafeBufferPointer { buffer in
                        guard let baseAddress = buffer.baseAddress else { return }
                        self.renderer.addPolyline(
                            with: baseAddress,
                            count: path.count,
                            color: color,
                            thickness: 4.0
                        )
                    }
                    
                    self.renderer.popClipRect()
                    
                case let .laserPointer(color):
                    renderer.beginDraw(
                        onTexture: canvas,
                        loadAction: .clear,
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
                    
                    path.withUnsafeBufferPointer { buffer in
                        guard let baseAddress = buffer.baseAddress else { return }
                        self.renderer.addPolyline(
                            with: baseAddress,
                            count: path.count,
                            color: color,
                            thickness: 6.0
                        )
                    }
                    
                    self.renderer.popClipRect()
                    
                default: ()
                }
                
                renderer.endDraw()
                self.mtkView.needsDisplay = true
            }
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
    
    private func setupCursor() {
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: Int(64),
            height: Int(64),
            mipmapped: false
        )
        desc.usage = [.renderTarget, .shaderRead, .shaderWrite]
        cursor = mtkView.device?.makeTexture(descriptor: desc)
    }
}

extension GlassBoardViewController: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setupCanvas(with: size)
    }

    public func draw(in view: MTKView) {
        guard let currentDrawable = mtkView.currentDrawable else { return }
        guard let canvas = canvas else { return }
        
        renderer.beginDraw(
            onDrawable: currentDrawable,
            loadAction: MTLLoadAction.clear,
            width: view.bounds.size.width,
            height: view.bounds.size.height,
            scale: view.window?.screen?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        )

        self.renderer.pushClipRect(.init(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height,
        ))
        
        self.renderer.addTexture(
            with: canvas,
            p1: .init(x: 0, y: 0),
            p2: .init(x: view.bounds.width, y: view.bounds.height),
            color: .white
        )
        
        if let cursor = cursor,
           let cursorLocation = viewStore.cursorLocation {
            let x = CGFloat(cursorLocation.x - 32)
            let y = CGFloat(cursorLocation.y - 32)
            let width = 64.0
            let height = 64.0
            
            self.renderer.pushClipRect(.init(
                x: x,
                y: y,
                width: width,
                height: height,
            ))
            
            self.renderer.addTexture(
                with: cursor,
                p1: .init(x: x, y: y),
                p2: .init(x: x + width, y: y + height),
                color: .black
            )
            
            self.renderer.popClipRect()
        }

        self.renderer.popClipRect()
        
        renderer.endDraw()
    }
}
