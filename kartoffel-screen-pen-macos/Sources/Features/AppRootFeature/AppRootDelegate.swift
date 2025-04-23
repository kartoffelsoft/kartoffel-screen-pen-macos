import ComposableArchitecture

public struct AppRootDelegate: Reducer {
    
    public struct State: Equatable {}
    
    public enum Action {
        
        case didFinishLaunching
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case start
        }
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                return .run { send in
                    await send(.delegate(.start))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
