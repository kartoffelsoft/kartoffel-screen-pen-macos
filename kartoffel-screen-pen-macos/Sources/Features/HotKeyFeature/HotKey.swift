import ComposableArchitecture
import Foundation

public struct HotKey: Reducer {

    public struct State: Equatable {

        var entries: IdentifiedArrayOf<HotKeyEntry> = []
        
        public init() {}
    }
    
    public enum Action {
        
        case register([HotKeyEntry])
        case unregister

        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case hotKeyDown(UInt32)
        }
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .register(entries):
                state.entries = IdentifiedArrayOf(uniqueElements: entries)
                return .none
                
            case .unregister:
                state.entries = []
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
