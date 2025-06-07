import Common
import ComposableArchitecture
import EventTapFeature
import Foundation
import GlassBoardFeature
import MenuFeature

public struct AppRoot: Reducer {

    public struct State: Equatable {

        var appRootDelegate: AppRootDelegate.State = .init()
        var eventTap: EventTap.State = .init()
        var fetchScreensSignal: Signal = .init()
        var glassBoards: IdentifiedArrayOf<GlassBoard.State> = []
        var menu: Menu.State = .init()
        var showGlassBoards: [UInt32] = []
        var drawingTool: DrawingTool = .none
        
        public init() {}
    }
    
    public enum Action {
        
        case updateGlassBoards([(UInt32, NSRect)])
        
        case appRootDelegate(AppRootDelegate.Action)
        case eventTap(EventTap.Action)
        case glassBoards(id: GlassBoard.State.ID, action: GlassBoard.Action)
        case menu(Menu.Action)
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateGlassBoards(screens):
                var updates: [(UInt32, CGRect)] = []
                
                let ids = Set(screens.map { $0.0 })
                state.glassBoards = state.glassBoards.filter { ids.contains($0.id) }
                state.showGlassBoards = []

                for screen in screens {
                    if let _ = state.glassBoards[id: screen.0] {
                        updates.append(screen)
                    } else {
                        state.glassBoards.append(.init(id: screen.0, frame: screen.1))
                    }
                    state.showGlassBoards.append(screen.0)
                }
                
                return .run { [updates = updates] send in
                    for update in updates {
                        await send(.glassBoards(id: update.0, action: .updateFrame(update.1)))
                    }
                }
                
            case .appRootDelegate(.delegate(.start)):
                state.fetchScreensSignal.fire()
                return .run { send in
                    await send(.menu(.setup))
                }
                
            case .appRootDelegate:
                return .none
                
            case .eventTap(.delegate(.escKeyDown)):
                state.drawingTool = .none
                return .run { [boardIds = state.glassBoards.map{$0.id}] send in
                    await send(.eventTap(.deactivate))
                    for id in boardIds {
                        await send(.glassBoards(id: id, action: .clear))
                    }
                }
                
            case let .eventTap(.delegate(.mouseMoved(location))):
                return .none
                
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
