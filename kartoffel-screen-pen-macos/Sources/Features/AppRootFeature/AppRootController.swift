import Cocoa
import Combine
import ComposableArchitecture

@MainActor
public class AppRootController {

    private let store: StoreOf<AppRoot>
    private let viewStore: ViewStoreOf<AppRoot>
    private var cancellables: Set<AnyCancellable> = []
    
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
    }
}
