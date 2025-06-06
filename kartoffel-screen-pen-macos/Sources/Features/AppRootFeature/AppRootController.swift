import AppKit
import AppKitUtils
import Combine
import ComposableArchitecture
import EventTapFeature
import GlassBoardFeature
import MenuFeature

public class AppRootController {

    private let store: StoreOf<AppRoot>
    private let viewStore: ViewStoreOf<AppRoot>
    private var cancellables: Set<AnyCancellable> = []
    
    private var glassBoardWindowControllers: IdentifiedArrayOf<GlassBoardWindowController> = []
    
    private let eventTapController: EventTapController
    private let menuController: MenuController

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
        viewStore.publisher.activeBoardId.sink { [weak self] id in
            guard let self = self else { return }
            guard let id = id else { return }
            glassBoardWindowControllers[id: id]?.window?.makeKeyAndOrderFront(nil)
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.createGlassBoardsSignal.sink { [weak self] signal in
            guard signal.isValid else { return }
            guard let self = self else { return }
            self.viewStore.send(.createGlassBoards(NSScreen.screens.map{$0.frame}))
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.showGlassBoards.sink { [weak self] data in
            guard let self = self else { return }
            guard data.count > 0 else {
                self.glassBoardWindowControllers.forEach { $0.window?.close() }
                self.glassBoardWindowControllers.removeAll()
                return
            }
            
            NSApp.activate(ignoringOtherApps: true)

            data.forEach { id in
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
    
    @objc func didChangeScreenParameters(_ notification: Notification) {
        for screen in NSScreen.screens {
            if let screenID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
            }
        }
    }
}
