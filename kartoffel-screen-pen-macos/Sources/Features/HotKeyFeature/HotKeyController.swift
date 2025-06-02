import Carbon
import Combine
import ComposableArchitecture

public class HotKeyController {

    private let store: StoreOf<HotKey>
    private let viewStore: ViewStoreOf<HotKey>
    private var cancellables: Set<AnyCancellable> = []

    @MainActor
    public init(store: StoreOf<HotKey>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        setupBindings()
    }

    @MainActor
    private func setupBindings() {
    }
}
