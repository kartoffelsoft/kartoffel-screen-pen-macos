import AppKit
import Combine
import ComposableArchitecture

public class EventTapController {

    private let store: StoreOf<EventTap>
    private let viewStore: ViewStoreOf<EventTap>
    private var cancellables: Set<AnyCancellable> = []
    
    @MainActor
    public init(store: StoreOf<EventTap>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        setupBindings()
    }
    
    deinit {
    }
    
    @MainActor
    private func setupBindings() {
        viewStore.publisher.isActive.sink { [weak self] isActive in
            guard let self = self else { return }
        }
        .store(in: &self.cancellables)
    }
}
