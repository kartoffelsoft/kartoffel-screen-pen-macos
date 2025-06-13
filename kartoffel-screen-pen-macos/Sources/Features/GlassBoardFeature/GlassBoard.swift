import Common
import ComposableArchitecture
import Foundation

public struct GlassBoard: Reducer {
    
    public struct State: Equatable, Identifiable {
        
        public let id: UInt32
        public var frame: NSRect
        public var currentDrawingTool: DrawingTool = .none
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
                state.drawings[lastIndex].drawingTool = state.currentDrawingTool
                state.drawings[lastIndex].add(point: point)
                return .none
                
            case .clear:
                state.drawings = []
                state.commandSignal = .init(.clear)
                return .none
                
            case let .continueDraw(point):
                guard let lastIndex = state.drawings.indices.last else { return .none }
                state.drawings[lastIndex].add(point: point)
                state.commandSignal = .init(.draw)
                return .none
            
            case .dismiss:
                return .run { send in
                    await send(.delegate(.dismiss))
                }
                
            case .eraseLast:
                _ = state.drawings.popLast()
                state.commandSignal = .init(.refresh)
                return .none
                
            case let .endDraw(point):
                guard let lastIndex = state.drawings.indices.last else { return .none}
                state.drawings[lastIndex].add(point: point)
                state.drawings[lastIndex].completedAt = Date()
                state.commandSignal = .init(.draw)
                
                if case .laserPointer = state.currentDrawingTool {
                    return .run { send in
                        await send(.clear)
                    }
                }
                return .none
                
            case let .selectDrawingTool(tool):
                state.currentDrawingTool = tool
                
                if case .laserPointer = state.currentDrawingTool {
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
