import AppKit
import Combine
import ComposableArchitecture

public class LocalEventMonitorController {

    private let store: StoreOf<LocalEventMonitor>
    private let viewStore: ViewStoreOf<LocalEventMonitor>
    private var cancellables: Set<AnyCancellable> = []
    
    private var monitor: Any?
    
    @MainActor
    public init(store: StoreOf<LocalEventMonitor>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        setupBindings()
    }
    
    deinit {
        removeMonitorIfNeeded()
    }
    
    @MainActor
    private func setupBindings() {
        viewStore.publisher.isActive.sink { [weak self] isActive in
            guard let self = self else { return }
            
            self.removeMonitorIfNeeded()
            
            if isActive {
                self.monitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved], handler: { event in
                    self.viewStore.send(.delegate(.mouseMoved(event.locationInWindow)))
                    return event;
                })
            }
        }
        .store(in: &self.cancellables)
    }
    
    private func removeMonitorIfNeeded() {
        if let monitor = self.monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
