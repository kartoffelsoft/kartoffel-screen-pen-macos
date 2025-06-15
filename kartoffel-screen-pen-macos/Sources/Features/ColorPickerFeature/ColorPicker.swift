import Common
import ComposableArchitecture
import CoreGraphics

public struct ColorPicker: Reducer {
    
    public struct State: Equatable {
        
        var colorButtons: IdentifiedArrayOf<ColorButtonData> = [
            .init(id: 1, color: .red),
            .init(id: 2, color: .orange),
            .init(id: 3, color: .yellow),
            .init(id: 4, color: .green),
            .init(id: 5, color: .cyan),
            .init(id: 6, color: .blue),
            .init(id: 7, color: .purple),
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
