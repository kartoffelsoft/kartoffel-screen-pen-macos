import AppKit
import Combine
import ComposableArchitecture

public class HelpViewController: NSViewController {

    private let store: StoreOf<Help>
    private let viewStore: ViewStoreOf<Help>
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var globalShortcutsView = {
        let view = NSStackView(views: [])
        view.orientation = .vertical
        view.spacing = 4
        return view
    }()
    
    private lazy var localShortcutsView = {
        let view = NSStackView(views: [])
        view.orientation = .vertical
        view.spacing = 4
        return view
    }()
    
    private lazy var contentView = {
        let view = NSStackView(views: [globalShortcutsView, localShortcutsView])
        view.orientation = .vertical
        view.spacing = 24
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
        view = NSView(frame: NSMakeRect(0, 0, 440, 440))
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
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ])
    }
    
    private func setupBindings() {
        viewStore.publisher.globalShortcuts.sink { [weak self] shortcuts in
            guard let self = self else { return }
            
            globalShortcutsView.arrangedSubviews.forEach { view in
                globalShortcutsView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for shortcut in shortcuts {
                let view = ShortcutView()
                view.render(shortcut)
                
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 480),
                    view.heightAnchor.constraint(equalToConstant: 24),
                ])

                globalShortcutsView.addArrangedSubview(view)
            }
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.localShortcuts.sink { [weak self] shortcuts in
            guard let self = self else { return }
            
            localShortcutsView.arrangedSubviews.forEach { view in
                localShortcutsView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for shortcut in shortcuts {
                let view = ShortcutView()
                view.render(shortcut)
                
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 480),
                    view.heightAnchor.constraint(equalToConstant: 24),
                ])

                localShortcutsView.addArrangedSubview(view)
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
