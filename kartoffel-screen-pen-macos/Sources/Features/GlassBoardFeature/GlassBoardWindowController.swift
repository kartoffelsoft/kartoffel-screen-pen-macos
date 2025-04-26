import Cocoa
import Combine
import ComposableArchitecture

public class GlassBoardWindowController: NSWindowController, Identifiable {
    
    public let id: UUID

    private let store: StoreOf<GlassBoard>
    private let viewStore: ViewStoreOf<GlassBoard>
    private var cancellables: Set<AnyCancellable> = []
    
    public init(id: UUID, store: StoreOf<GlassBoard>) {
        self.id = id
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    
        super.init(window: GlassBoardWindow())

        contentViewController = GlassBoardViewController(
            store: store
        )
        
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewStore.publisher.frame.sink { [weak self] data in
            guard let self = self else { return }
            self.window?.setFrame(data, display: true)
        }
        .store(in: &self.cancellables)
    }

}
