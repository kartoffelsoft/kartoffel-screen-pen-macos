import ComposableArchitecture
import HotKeyFeature

public struct Menu: Reducer {
    
    public struct State: Equatable {
        
        var hotKey: HotKey.State = .init()
        
        public init() {}
    }
    
    public enum Action {

        case hotKey(HotKey.Action)
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
            case .hotKey:
                return .none
                
            case .start:
                return .run { send in
                }
                
            case .delegate:
                return .none
            }
        }
        Scope(state: \.hotKey, action: /Action.hotKey) {
            HotKey()
        }
    }
}
