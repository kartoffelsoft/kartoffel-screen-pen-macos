import AppKit
import ComposableArchitecture

public class HelpViewController: NSViewController {

    private let store: StoreOf<Help>
    private let viewStore: ViewStoreOf<Help>
    
    private lazy var contentView = {
        let view = NSStackView(views: [])
        view.orientation = .vertical
        view.spacing = 16
        return view
    }()
    
    public init(store: StoreOf<Help>) {
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
    }
    
    public override var representedObject: Any? {
        didSet {
        }
    }
    
    public override func loadView() {
        view = NSView(frame: NSMakeRect(0, 0, 800, 460))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        view.window?.performDrag(with: event)
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.80),
        ])
    }
    
    private func setupBindings() {
    }
}

extension HelpViewController: NSWindowDelegate {
    
    public func windowWillClose(_ notification: Notification) {
        viewStore.send(.delegate(.dismiss))
    }
}
