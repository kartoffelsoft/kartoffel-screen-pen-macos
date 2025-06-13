import AppKit
import Combine
import ComposableArchitecture

public class HelpViewController: NSViewController {

    private let store: StoreOf<Help>
    private let viewStore: ViewStoreOf<Help>
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var stackView = {
        let view = NSStackView(views: [])
        view.orientation = .vertical
        view.spacing = 4
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
        view = NSView(frame: NSMakeRect(0, 0, 640, 320))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        view.window?.performDrag(with: event)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.80),
        ])
    }
    
    private func setupBindings() {
        viewStore.publisher.shortcuts.sink { [weak self] shortcuts in
            guard let self = self else { return }
            
            stackView.arrangedSubviews.forEach { view in
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for shortcut in shortcuts {
                let view = ShortcutView()
                view.render(shortcut)
                
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 480),
                    view.heightAnchor.constraint(equalToConstant: 32),
                ])

                stackView.addArrangedSubview(view)
            }
        }
        .store(in: &self.cancellables)
    }
}

extension HelpViewController: NSWindowDelegate {
    
    public func windowWillClose(_ notification: Notification) {
        viewStore.send(.dismiss)
    }
}
