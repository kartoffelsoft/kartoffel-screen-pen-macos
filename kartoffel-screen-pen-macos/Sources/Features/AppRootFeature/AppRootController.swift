import Cocoa
import Combine
import ComposableArchitecture
import GlassBoardFeature

@MainActor
public class AppRootController {

    private let store: StoreOf<AppRoot>
    private let viewStore: ViewStoreOf<AppRoot>
    private var cancellables: Set<AnyCancellable> = []
    
    private var glassBoardWindowControllers: IdentifiedArrayOf<GlassBoardWindowController> = []
    private let menuController: MenuController

    public init(store: StoreOf<AppRoot>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        self.menuController = .init(store: self.store.scope(
            state: \.menu,
            action: AppRoot.Action.menu
        ))
        
        self.menuController.load()
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewStore.publisher.showGlassBoards.sink { [weak self] data in
            guard let self = self else { return }
            guard data.count > 0 else {
                self.glassBoardWindowControllers.forEach { $0.window?.close() }
                self.glassBoardWindowControllers.removeAll()
                return
            }
            
            print("data count: ", data.count)
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
        
        viewStore.publisher.createGlassBoards.sink { [weak self] data in
            guard data.isValid else { return }
            guard let self = self else { return }
            self.viewStore.send(.createGlassBoards(NSScreen.screens.map{$0.frame}))
        }
        .store(in: &self.cancellables)
    }
}
