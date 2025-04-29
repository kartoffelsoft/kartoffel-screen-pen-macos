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

    public override func viewWillAppear() {
        super.viewWillAppear()
        self.view.window?.setFrame(viewStore.frame, display: true)
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    public override var representedObject: Any? {
        didSet {
        }
    }
    
    public override func loadView() {
        let view = GlassBoardView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.uiDelegate = self
        self.view = view
    }
    
//    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
//        print("# performKeyEquivalent");
//        viewStore.send(.delegate(.dismiss))
//        
//        return true
//    }
    
    public override func keyUp(with event: NSEvent) {
        print("# keyUp");
        super.keyUp(with: event)
        viewStore.send(.delegate(.dismiss))
    }

    private func setupConstraints() {
    }
    
    private func setupBindings() {
    }
}

extension GlassBoardViewController: GlassBoardViewDelegate {
    
    func didKeyUp() {
        viewStore.send(.delegate(.dismiss))
    }
}
