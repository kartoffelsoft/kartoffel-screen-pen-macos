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
    @objc func didChangeScreenParameters(_ notification: Notification) {
        fetchScreens()
    }
}
