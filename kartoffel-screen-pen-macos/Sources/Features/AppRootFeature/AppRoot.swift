import Common
import ComposableArchitecture
import EventTapFeature
import Foundation
import GlassBoardFeature
import MenuFeature

public struct AppRoot: Reducer {

    public struct State: Equatable {

        var activeBoardId: UUID?
        var appRootDelegate: AppRootDelegate.State = .init()
        var createGlassBoardsSignal: Signal = .init()
        var eventTap: EventTap.State = .init()
        var glassBoards: IdentifiedArrayOf<GlassBoard.State> = []
        var menu: Menu.State = .init()
        var showGlassBoards: [UUID] = []
        var drawingTool: DrawingTool = .none
        
        public init() {}
    }
    
    public enum Action {
        
        case createGlassBoards([NSRect])
        
        case appRootDelegate(AppRootDelegate.Action)
        case eventTap(EventTap.Action)
        case glassBoards(id: GlassBoard.State.ID, action: GlassBoard.Action)
        case menu(Menu.Action)
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .createGlassBoards(screenFrames):
                for frame in screenFrames {
                    let id = UUID()
                    state.glassBoards.append(.init(id: id, frame: frame))
                    state.showGlassBoards.append(id)
                }

                return .none
                
            case .appRootDelegate(.delegate(.start)):
                state.createGlassBoardsSignal.fire()
                return .run { send in
                    await send(.menu(.setup))
                }
                
            case .appRootDelegate:
                return .none
                
            case .eventTap(.delegate(.escKeyDown)):
                state.drawingTool = .none
                return .run { send in
                    await send(.eventTap(.deactivate))
                }
                
            case let .eventTap(.delegate(.leftMouseDown(location))):
                if let board = state.glassBoards.first(where: { $0.frame.contains(location) }) {
                    return .run { [id = board.id] send in
                        await send(.glassBoards(id: id, action: .beginDraw(location)))
                    }
                }
                return .none
                
            case let .eventTap(.delegate(.leftMouseDragged(location))):
                if let board = state.glassBoards.first(where: { $0.frame.contains(location) }) {
                    return .run { [id = board.id] send in
                        await send(.glassBoards(id: id, action: .continueDraw(location)))
                    }
                }
                return .none

            case let .eventTap(.delegate(.leftMouseUp(location))):
                if let board = state.glassBoards.first(where: { $0.frame.contains(location) }) {
                    return .run { [id = board.id] send in
                        await send(.glassBoards(id: id, action: .endDraw(location)))
                    }
                }
                return .none
                
            case .eventTap:
                return .none
                
            case .glassBoards:
                return .none
                
            case .menu(.delegate(.selectPen)):
                state.drawingTool = .pen(color: .white)
                return .run { send in
                    await send(.eventTap(.activate))
                }
                
            case .menu(.delegate(.selectLaserPointer)):
                state.drawingTool = .laserPointer
                return .run { send in
                    await send(.eventTap(.activate))
                }
                
            case .menu:
                return .none
            }
        }
        Scope(state: \.appRootDelegate, action: /Action.appRootDelegate) {
            AppRootDelegate()
        }
        Scope(state: \.eventTap, action: /Action.eventTap) {
            EventTap()
        }
        Scope(state: \.menu, action: /Action.menu) {
            Menu()
        }
        .forEach(\.glassBoards, action: /Action.glassBoards) {
            GlassBoard()
        }
    }
}
