import AppKit
import AppKitUtils
import Combine
import ComposableArchitecture
import EventTapFeature
import GlassBoardFeature
import MenuFeature
import StyleGuide

public class AppRootController {

    private let store: StoreOf<AppRoot>
    private let viewStore: ViewStoreOf<AppRoot>
    private var cancellables: Set<AnyCancellable> = []
    
    private var glassBoardWindowControllers: IdentifiedArrayOf<GlassBoardWindowController> = []
    
    private let eventTapController: EventTapController
    private let menuController: MenuController

    private var cursorWindow: NSWindow!
    
    @MainActor
    public init(store: StoreOf<AppRoot>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        self.eventTapController = .init(store: self.store.scope(
            state: \.eventTap,
            action: AppRoot.Action.eventTap
        ))
        
        self.menuController = .init(store: self.store.scope(
            state: \.menu,
            action: AppRoot.Action.menu
        ))
        
        setupBindings()
        setupCursorWindow()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeScreenParameters),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor
    private func setupBindings() {
        viewStore.publisher.cursorLocation.sink { [weak self] location in
            guard let self = self else { return }
            guard let location = location else { return }
            
            let screenHeight = NSScreen.main?.frame.height ?? 0

            let cursorSize = cursorWindow.frame.size
            let x = location.x - cursorSize.width / 2
            let y = screenHeight - location.y - cursorSize.height / 2

            self.cursorWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.drawingTool.sink { [weak self] tool in
            switch tool {
            case let .pen(color):
                break
                
            case .laserPointer:
                CGWarpMouseCursorPosition(CGPoint(x: 0, y: 0))
                break
                
            case .eraser:
                break
                
            default:
                break
            }
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.fetchScreensSignal.sink { [weak self] signal in
            guard signal.isValid else { return }
            guard let self = self else { return }
            self.fetchScreens()
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.showGlassBoards.sink { [weak self] ids in
            guard let self = self else { return }
            guard ids.count > 0 else {
                self.glassBoardWindowControllers.forEach { $0.window?.close() }
                self.glassBoardWindowControllers.removeAll()
                return
            }

            for id in glassBoardWindowControllers.map(\.id) where !ids.contains(id) {
                glassBoardWindowControllers[id: id]?.window?.close()
                glassBoardWindowControllers.remove(id: id)
            }
            
            ids.forEach { id in
                guard glassBoardWindowControllers[id: id] == nil else { return }
                
                let controller = GlassBoardWindowController(id: id)

                controller.contentViewController = IfLetStoreController(store: self.store.scope(
                    state: { $0.glassBoards[id: id] },
                    action: { .glassBoards(id: id, action: $0) }
                )) {
                    GlassBoardViewController(store: $0)
                } else: {
                    NSViewController()
                }
                
                controller.showWindow(self)
                self.glassBoardWindowControllers.append(controller)
            }
        }
        .store(in: &self.cancellables)
    }
    
    @MainActor
    private func fetchScreens() {
        let screens: [(UInt32, NSRect)] = NSScreen.screens.compactMap { screen in
            guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32 else {
                return nil
            }
            return (id, screen.frame)
        }
        
        self.viewStore.send(.updateGlassBoards(screens))
    }
    
    @MainActor
    private func setupCursorWindow() {
        cursorWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 32, height: 32),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        cursorWindow.level = .screenSaver
        cursorWindow.isOpaque = false
        cursorWindow.backgroundColor = .clear
        cursorWindow.hasShadow = false
        cursorWindow.ignoresMouseEvents = true
        cursorWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let imageView = NSImageView(frame: cursorWindow.contentView!.bounds)
        imageView.image = NSImage.theme.appIcon
        imageView.image?.isTemplate = false
        imageView.imageScaling = .scaleProportionallyUpOrDown
        cursorWindow.contentView?.addSubview(imageView)

        cursorWindow.makeKeyAndOrderFront(nil)
    }
    
    @MainActor
    @objc func didChangeScreenParameters(_ notification: Notification) {
        fetchScreens()
    }
}
