import ComposableArchitecture
import CoreGraphics

public struct ColorPicker: Reducer {
    
    public struct State: Equatable {
        
        var colorButtons: IdentifiedArrayOf<ColorButtonData> = [
            .init(id: 1, color: .init(red: 255/255, green:   0/255, blue:   0/255, alpha: 1)),
            .init(id: 2, color: .init(red: 255/255, green: 165/255, blue:   0/255, alpha: 1)),
            .init(id: 3, color: .init(red: 255/255, green: 255/255, blue:   0/255, alpha: 1)),
            .init(id: 4, color: .init(red:   0/255, green: 255/255, blue:   0/255, alpha: 1)),
            .init(id: 5, color: .init(red:   0/255, green: 255/255, blue: 255/255, alpha: 1)),
            .init(id: 6, color: .init(red:   0/255, green:   0/255, blue: 255/255, alpha: 1)),
            .init(id: 7, color: .init(red: 128/255, green:   0/255, blue: 128/255, alpha: 1)),
        ]
        var selectedButtonId: Int = 1
        
        public init() {
            colorButtons[id: selectedButtonId]?.isSelected = true
        }
    }
    
    public enum Action {
        
        case selectButton(Int)
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {

            case selectColor(CGColor)
        }
    }

    public init() {
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectButton(id):
                state.colorButtons = IdentifiedArrayOf(
                    uniqueElements: state.colorButtons.map({ button in
                        var updated = button
                        updated.isSelected = (button.id == id)
                        return updated
                    })
                )
                guard let color = state.colorButtons[id: id]?.color else { return .none }
                return .run { [color = color] send in
                    await send(.delegate(.selectColor(color)))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
