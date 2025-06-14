import Common
import ComposableArchitecture
import CoreGraphics
import EventTapFeature
import Foundation
import GlassBoardFeature
import HelpFeature
import MenuFeature
import SettingsFeature

public struct AppRoot: Reducer {

    public struct State: Equatable {

        var appRootDelegate: AppRootDelegate.State = .init()
        var eventTap: EventTap.State = .init()
        var fetchScreensSignal: Signal<Void>?
        var glassBoards: IdentifiedArrayOf<GlassBoard.State> = []
        var help: Help.State?
        var menu: Menu.State = .init()
        var settings: Settings.State?
        var showGlassBoards: [UInt32] = []
        var showHelpSignal: Signal<Bool>?
        var showSettingsSignal: Signal<Bool>?
        var drawingTool: DrawingTool = .none
        var color: CGColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
        
        public init() {}
    }
    
    public enum Action {
        
        case notifyGlassBoardsDrawToolChange
        case updateGlassBoards([(UInt32, NSRect)])
        
        case appRootDelegate(AppRootDelegate.Action)
        case eventTap(EventTap.Action)
        case glassBoards(id: GlassBoard.State.ID, action: GlassBoard.Action)
        case help(Help.Action)
        case menu(Menu.Action)
        case settings(Settings.Action)
    }

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .notifyGlassBoardsDrawToolChange:
                return .run { [boardIds = state.glassBoards.map{$0.id}, drawingTool = state.drawingTool] send in
                    await send(.eventTap(.activate))
                    for id in boardIds {
                        await send(.glassBoards(id: id, action: .selectDrawingTool(drawingTool)))
                    }
                }
                
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
                state.fetchScreensSignal = .init()
                return .run { send in
                    await send(.menu(.activateHotKey))
                }
                
            case .appRootDelegate:
                return .none
                
            case let .eventTap(.delegate(.commandKeyDownWith(key))):
                switch key {
                case "1":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(1))))
                    }
                case "2":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(2))))
                    }
                case "3":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(3))))
                    }
                case "4":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(4))))
                    }
                case "5":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(5))))
                    }
                case "6":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(6))))
                    }
                case "7":
                    return .run { send in
                        await send(.menu(.colorPicker(.selectButton(7))))
                    }
                case "p":
                    return .run { send in
                        await send(.menu(.delegate(.selectDrawingTool(.pen(color: .clear)))))
                    }
                case "l":
                    return .run { send in
                        await send(.menu(.delegate(.selectDrawingTool(.laserPointer(color: .clear)))))
                    }
                case "z":
                    guard case .pen = state.drawingTool else { return .none }
                    let targetId = state.glassBoards
                        .compactMap { board -> (id: UInt32, date: Date)? in
                            guard let date = board.drawings.last?.completedAt else { return nil }
                            return (id: board.id, date: date)
                        }
                        .max(by: { $0.date < $1.date })?
                        .id
                    
                    guard let targetId = targetId else { return .none }
                    return .run { send in
                        await send(.glassBoards(id: targetId, action: .eraseLast))
                    }
                case "n":
                    guard case .pen = state.drawingTool else { return .none }
                    return .run { [boardIds = state.glassBoards.map{$0.id}] send in
                        for id in boardIds {
                            await send(.glassBoards(id: id, action: .clear))
                        }
                    }
                default:
                    break
                }
                return .none
                
            case .eventTap(.delegate(.escKeyDown)):
                state.drawingTool = .none
                return .run { [boardIds = state.glassBoards.map{$0.id}] send in
                    await send(.eventTap(.deactivate))
                    for id in boardIds {
                        await send(.glassBoards(id: id, action: .clear))
                    }
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
                
            case .help(.delegate(.dismiss)):
                state.help = nil
                state.showHelpSignal = .init(false)
                return .none
                
            case .help:
                return .none
                
            case .menu(.delegate(.openHelp)):
                state.help = .init()
                state.showHelpSignal = .init(true)
                return .none
            
            case .menu(.delegate(.openPermission)):
                return .run { send in
                    await send(.appRootDelegate(.openPermission))
                }
                
            case .menu(.delegate(.openSettings)):
                state.settings = .init()
                state.showSettingsSignal = .init(true)
                return .none
                
            case let .menu(.delegate(.selectDrawingTool(drawingTool))):
                state.drawingTool = drawingTool.with(color: state.color)
                return .run { [boardIds = state.glassBoards.map{$0.id}, drawingTool = state.drawingTool] send in
                    await send(.eventTap(.activate))
                    for id in boardIds {
                        await send(.glassBoards(id: id, action: .selectDrawingTool(drawingTool)))
                    }
                }
                
            case let .menu(.colorPicker(.delegate(.selectColor(color)))):
                state.color = color
                let prevDrawTool = state.drawingTool
                state.drawingTool = state.drawingTool.with(color: state.color)
                
                if state.drawingTool == prevDrawTool {
                    return .none
                }
                
                return .run { send in
                    await send(.notifyGlassBoardsDrawToolChange)
                }
                
            case .menu:
                return .none
                
            case .settings(.delegate(.dismiss)):
                state.settings = nil
                state.showSettingsSignal = .init(false)
                return .none
                
            case .settings:
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
        .ifLet(\.help, action: /Action.help) {
            Help()
        }
        .ifLet(\.settings, action: /Action.settings) {
            Settings()
        }
    }
}
