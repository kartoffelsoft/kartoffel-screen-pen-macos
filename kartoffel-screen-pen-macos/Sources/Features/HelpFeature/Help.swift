import ComposableArchitecture

public struct Help: Reducer {
    
    public struct State: Equatable {
        
        var globalShortcuts: [ShortcutData] = [
            .init(
                keyEquivalent: "K",
                keyEquivalentModifiers: [.control, .option, .command],
                description: .text("Open the menu (only works outside of drawing mode)")
            ),
        ]
        
        var localShortcuts: [ShortcutData] = [
            .init(
                keyEquivalent: "ESC",
                keyEquivalentModifiers: [],
                description: .text("Exit drawing mode")
            ),
            .init(
                keyEquivalent: "P",
                keyEquivalentModifiers: [.command],
                description: .text("Switch to Pen")
            ),
            .init(
                keyEquivalent: "L",
                keyEquivalentModifiers: [.command],
                description: .text("Switch to Laser Pointer")
            ),
            .init(
                keyEquivalent: "N",
                keyEquivalentModifiers: [.command],
                description: .text("Erase all drawings")
            ),
            .init(
                keyEquivalent: "Z",
                keyEquivalentModifiers: [.command],
                description: .text("Undo drawing")
            ),
            .init(
                keyEquivalent: "1",
                keyEquivalentModifiers: [.command],
                description: .color(.red)
            ),
            .init(
                keyEquivalent: "2",
                keyEquivalentModifiers: [.command],
                description: .color(.orange)
            ),
            .init(
                keyEquivalent: "3",
                keyEquivalentModifiers: [.command],
                description: .color(.yellow)
            ),
            .init(
                keyEquivalent: "4",
                keyEquivalentModifiers: [.command],
                description: .color(.green)
            ),
            .init(
                keyEquivalent: "5",
                keyEquivalentModifiers: [.command],
                description: .color(.cyan)
            ),
            .init(
                keyEquivalent: "6",
                keyEquivalentModifiers: [.command],
                description: .color(.blue)
            ),
            .init(
                keyEquivalent: "7",
                keyEquivalentModifiers: [.command],
                description: .color(.purple)
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
