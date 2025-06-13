import ComposableArchitecture

public struct Help: Reducer {
    
    public struct State: Equatable {
        
        var shortcuts: [ShortcutData] = [
            .init(
                keyEquivalent: "P",
                keyEquivalentModifiers: [.command],
                description: "Select Pen"
            ),
            .init(
                keyEquivalent: "L",
                keyEquivalentModifiers: [.command],
                description: "Select Laser Pointer"
            ),
            .init(
                keyEquivalent: "1",
                keyEquivalentModifiers: [.command],
                description: "Red"
            ),
        ]
        
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
