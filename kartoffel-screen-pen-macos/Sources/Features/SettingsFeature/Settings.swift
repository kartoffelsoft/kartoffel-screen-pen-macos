import ComposableArchitecture

public struct Settings: Reducer {
    
    public struct State: Equatable {
        
        public init() {}
    }
    
    public enum Action {
        
        case dismiss
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case dismiss
        }
    }
    
    public init() {
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { send in
                    await send(.delegate(.dismiss))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
