import ComposableArchitecture

public struct Settings: Reducer {
    
    public struct State: Equatable {
        
        public init() {}
    }
    
    public enum Action {
        
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
            case .delegate:
                return .none
            }
        }
    }
}
