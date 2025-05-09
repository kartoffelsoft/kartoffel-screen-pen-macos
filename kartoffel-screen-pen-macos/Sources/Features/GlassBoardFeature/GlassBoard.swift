import Common
import ComposableArchitecture
import Foundation

public struct GlassBoard: Reducer {
    
    public struct State: Equatable, Identifiable {
        
        public let id: UUID
        public let frame: NSRect
        public var currentDrawingTool: DrawingTool = .pen(color: .blue)
        public var drawings: [DrawingData] = []
        
        public init(id: UUID, frame: NSRect) {
            self.id = id
            self.frame = frame
        }
    }
    
    public enum Action {
        
        case startDrawing(CGPoint)
        case continueDrawing(CGPoint)
        case endDrawing(CGPoint)
        
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
            case let .startDrawing(point):
                state.drawings.append(.init())

                guard let lastIndex = state.drawings.indices.last else { return .none}
                state.drawings[lastIndex].add(point: point)
                return .none
                
            case let .continueDrawing(point):
                guard let lastIndex = state.drawings.indices.last else { return .none}
                state.drawings[lastIndex].add(point: point)
                return .none
            
            case let .endDrawing(point):
                guard let lastIndex = state.drawings.indices.last else { return .none}
                state.drawings[lastIndex].add(point: point)
                return .none
            
            case .delegate:
                return .none
            }
        }
    }
}
