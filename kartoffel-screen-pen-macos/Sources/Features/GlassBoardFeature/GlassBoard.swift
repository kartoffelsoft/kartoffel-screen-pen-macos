import Common
import ComposableArchitecture
import Foundation

public struct GlassBoard: Reducer {
    
    public struct State: Equatable, Identifiable {
        
        public let id: UInt32
        var cursorLocation: CGPoint?
        public var frame: NSRect
        var drawingTool: DrawingTool = .none
        public var drawings: [DrawingData] = []
        
        var commandSignal: Signal<DrawingCommand>?
        
        public init(id: UInt32, frame: NSRect) {
            self.id = id
            self.frame = frame
        }
    }
    
    public enum Action {
        
        case beginDraw(CGPoint)
        case clear
        case continueDraw(CGPoint)
        case cursorLocation(CGPoint)
        case dismiss
        case eraseLast
        case endDraw(CGPoint)
        case selectDrawingTool(DrawingTool)
        case updateFrame(CGRect)
        
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
            case let .beginDraw(point):
                state.drawings.append(.init())

                guard let lastIndex = state.drawings.indices.last else { return .none }
                state.drawings[lastIndex].drawingTool = state.drawingTool
                state.drawings[lastIndex].add(point: point)
                state.cursorLocation = point
                state.commandSignal = .init(.refresh)
                return .none
                
            case .clear:
                state.drawings = []
                state.commandSignal = .init(.clear)
                return .none
                
            case let .continueDraw(point):
                guard let lastIndex = state.drawings.indices.last else { return .none }
                state.drawings[lastIndex].add(point: point)
                state.cursorLocation = point
                state.commandSignal = .init(.draw)
                return .none
            
            case let .cursorLocation(location):
                guard state.frame.contains(location) else {
                    state.cursorLocation = nil
                    return .none
                }
                state.cursorLocation = location
                state.commandSignal = .init(.refresh)
                return .none
                
            case .dismiss:
                return .run { send in
                    await send(.delegate(.dismiss))
                }
                
            case .eraseLast:
                _ = state.drawings.popLast()
                state.commandSignal = .init(.redraw)
                return .none
                
            case let .endDraw(point):
                guard let lastIndex = state.drawings.indices.last else { return .none}
                state.drawings[lastIndex].add(point: point)
                state.drawings[lastIndex].completedAt = Date()
                state.cursorLocation = point
                state.commandSignal = .init(.draw)
                
                if case .laserPointer = state.drawingTool {
                    return .run { send in
                        await send(.clear)
                    }
                }
                return .none
                
            case let .selectDrawingTool(tool):
                state.drawingTool = tool
                
                if case .laserPointer = state.drawingTool {
                    return .run { send in
                        await send(.clear)
                    }
                }
                return .none
                
            case let .updateFrame(frame):
                state.frame = frame
                state.drawings = []
                state.commandSignal = .init(.clear)
                return .none
            
            case .delegate:
                return .none
            }
        }
    }
}
