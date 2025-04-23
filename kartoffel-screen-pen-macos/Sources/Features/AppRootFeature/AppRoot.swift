import ComposableArchitecture

public struct AppRoot: Reducer {

    public struct State: Equatable {
        
        var appRootDelegate: AppRootDelegate.State = .init()
        var menu: Menu.State = .init()
        
        public init() {}
    }
    
    public enum Action {
        
        case appRootDelegate(AppRootDelegate.Action)
        case menu(Menu.Action)
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appRootDelegate(.delegate(.start)):
                return .none
                
            case .appRootDelegate:
                return .none
                
            case .menu:
                return .none
            }
        }
        Scope(state: \.appRootDelegate, action: /Action.appRootDelegate) {
            AppRootDelegate()
        }
        Scope(state: \.menu, action: /Action.menu) {
            Menu()
        }
    }
}
