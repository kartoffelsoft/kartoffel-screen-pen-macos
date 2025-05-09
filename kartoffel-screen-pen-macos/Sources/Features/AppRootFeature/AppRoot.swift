import Common
import ComposableArchitecture
import Foundation
import GlassBoardFeature

public struct AppRoot: Reducer {

    public struct State: Equatable {
        
        var appRootDelegate: AppRootDelegate.State = .init()
        var createGlassBoards: Signal = .init()
        var glassBoards: IdentifiedArrayOf<GlassBoard.State> = []
        var menu: Menu.State = .init()
        var showGlassBoards: [UUID] = []
        var drawingTool: DrawingTool = .none
        
        public init() {}
    }
    
    public enum Action {
        
        case createGlassBoards([NSRect])
        
        case appRootDelegate(AppRootDelegate.Action)
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
                return .none
                
            case .appRootDelegate:
                return .none
                
            case let .glassBoards(id: id, action: .delegate(.dismiss)):
                state.glassBoards.removeAll()
                state.showGlassBoards.removeAll()
                state.drawingTool = .none
                return .none
                
            case .glassBoards:
                return .none

            case .menu(.delegate(.selectPen)):
                state.drawingTool = .pen(color: .white)
                state.createGlassBoards.fire()
                return .none
                
            case .menu(.delegate(.selectLaserPointer)):
                state.drawingTool = .laserPointer
                state.createGlassBoards.fire()
                return .none
                
            case .menu:
                return .none
            }
        }
        Scope(state: \.appRootDelegate, action: /Action.appRootDelegate) {
            AppRootDelegate()
        }
        Scope(state: \.menu, action: /Action.menu) {
            Menu()
        }
        .forEach(\.glassBoards, action: /Action.glassBoards) {
            GlassBoard()
        }
    }
}
