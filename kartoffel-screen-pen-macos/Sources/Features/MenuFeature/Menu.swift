import ComposableArchitecture
import HotKeyFeature

public struct Menu: Reducer {
    
    public struct State: Equatable {
        
        var hotKey: HotKey.State
        
        let hotKeyEntries: [HotKeyEntry] = [
            .init(
                id: MenuKey.pen.rawValue,
                keyEquivalent: "p",
                keyEquivalentModifierMask: [.control, .option, .command]
            ),
            .init(
                id: MenuKey.laserPointer.rawValue,
                keyEquivalent: "l",
                keyEquivalentModifierMask: [.control, .option, .command]
            ),
        ]
        
        public init() {
            self.hotKey = .init(entries: hotKeyEntries)
        }
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
            case let .hotKey(.delegate(.hotKeyDown(id))):
                guard let menuKey = MenuKey(rawValue: id) else { return .none }
                
                switch menuKey {
                case .pen:
                    break
                case .laserPointer:
                    break
                }
                
                return .none
                
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
