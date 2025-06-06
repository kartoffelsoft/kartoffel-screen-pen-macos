import ComposableArchitecture
import Foundation

public struct EventTap: Reducer {

    public struct State: Equatable {
        
        public var isActive = false;
        
        public init() {}
    }
    
    public enum Action {
        
        case activate
        case deactivate
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {

            case escKeyDown
            case leftMouseDown(CGPoint)
            case leftMouseDragged(CGPoint)
            case leftMouseUp(CGPoint)
        }
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .activate:
                state.isActive = true
                return .none
                
            case .deactivate:
                state.isActive = false
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
