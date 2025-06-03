import ComposableArchitecture
import Foundation

public struct HotKey: Reducer {

    public struct State: Equatable {

        var entries: IdentifiedArrayOf<HotKeyEntry>
        
        public init(entries: [HotKeyEntry]) {
            self.entries = IdentifiedArrayOf(uniqueElements: entries)
        }
    }
    
    public enum Action {

        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case hotKeyDown(UInt32)
        }
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .delegate:
                return .none
            }
        }
    }
}
