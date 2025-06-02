import ComposableArchitecture
import Foundation

public struct HotKey: Reducer {

    public struct State: Equatable {
        
        public init() {}
    }
    
    public enum Action {
        
        case register
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case hotKeyDown
        }
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .register:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
