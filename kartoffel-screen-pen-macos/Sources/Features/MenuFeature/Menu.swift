import ColorPickerFeature
import Common
import ComposableArchitecture
import HotKeyFeature

public struct Menu: Reducer {
    
    public struct State: Equatable {
        
        var colorPicker: ColorPicker.State = .init()
        var hotKey: HotKey.State = .init()
        var openMenuSignal: Signal = .init()
        
        let hotKeyEntries: [HotKeyEntry] = [
            .init(
                id: MenuKey.openMenu.rawValue,
                keyEquivalent: "k",
                keyEquivalentModifierMask: [.control, .option, .command]
            ),
        ]
        
        public init() {}
    }
    
    public enum Action {

        case activateHotKey
        case colorPicker(ColorPicker.Action)
        case deactivateHotKey
        case hotKey(HotKey.Action)
        case openMenu
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {

            case openHelp
            case selectDrawingTool(DrawingTool)
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .activateHotKey:
                return .run { [entries = state.hotKeyEntries] send in
                    await send(.hotKey(.register(entries)))
                }
                
            case .colorPicker:
                return .none
                
            case .deactivateHotKey:
                return .run { send in
                    await send(.hotKey(.unregister))
                }
            
            case let .hotKey(.delegate(.hotKeyDown(id))):
                guard let menuKey = MenuKey(rawValue: id) else { return .none }
                
                switch menuKey {
                case .openMenu:
                    return .run { send in
                        await send(.deactivateHotKey)
                        await send(.openMenu)
                    }
                }
                
                return .none
                
            case .hotKey:
                return .none
                
            case .openMenu:
                state.openMenuSignal.fire()
                return .none
                
            case .delegate:
                return .none
            }
        }
        Scope(state: \.colorPicker, action: /Action.colorPicker) {
            ColorPicker()
        }
        Scope(state: \.hotKey, action: /Action.hotKey) {
            HotKey()
        }
    }
}
