import Cocoa
import Combine
import ComposableArchitecture

public final class IfLetStoreController<State, Action>: NSViewController {
    
    let store: Store<State?, Action>
    let ifDestination: (Store<State, Action>) -> NSViewController
    let elseDestination: () -> NSViewController
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewController = NSViewController() {
        willSet {
            self.viewController.view.removeFromSuperview()
            self.viewController.removeFromParent()
            self.addChild(newValue)
            self.view.addSubview(newValue.view)
        }
    }
    
    public init(
        store: Store<State?, Action>,
        then ifDestination: @escaping (Store<State, Action>) -> NSViewController,
        else elseDestination: @escaping () -> NSViewController
    ) {
        self.store = store
        self.ifDestination = ifDestination
        self.elseDestination = elseDestination
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.store.ifLet(
            then: { [weak self] store in
                guard let self = self else { return }
                self.viewController = self.ifDestination(store)
            },
            else: { [weak self] in
                guard let self = self else { return }
                self.viewController = self.elseDestination()
            }
        )
        .store(in: &self.cancellables)
    }
}
