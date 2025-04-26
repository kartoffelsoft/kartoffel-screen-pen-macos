import Cocoa
import Combine
import ComposableArchitecture

public class GlassBoardViewController: NSViewController {

    private let store: StoreOf<GlassBoard>
    private let viewStore: ViewStoreOf<GlassBoard>
    private var cancellables: Set<AnyCancellable> = []
    
    public init(store: StoreOf<GlassBoard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupBindings()
    }

    public override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
        view.window?.makeFirstResponder(self);
    }
    
    public override var representedObject: Any? {
        didSet {
        }
    }
    
    public override func loadView() {
        view = NSView(frame: .zero)
        view.wantsLayer = true;
        view.layer?.backgroundColor = .clear
    }
    
    public override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        viewStore.send(.delegate(.dismiss))
    }
    
    private func setupConstraints() {
    }
    
    private func setupBindings() {
    }
}

extension GlassBoardViewController: NSWindowDelegate {
    
    public func windowWillClose(_ notification: Notification) {
        viewStore.send(.delegate(.dismiss))
    }
}
