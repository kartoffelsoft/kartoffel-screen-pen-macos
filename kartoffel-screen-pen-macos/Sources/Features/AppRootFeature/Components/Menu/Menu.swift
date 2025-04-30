import ComposableArchitecture

public struct Menu: Reducer {
    
    public struct State: Equatable {
        
        public init() {}
    }
    
    public enum Action {
        
        case start
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case selectPen
            case selectLaserPointer
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                return .run { send in
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
