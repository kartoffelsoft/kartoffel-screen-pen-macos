import Common
import ComposableArchitecture
import Foundation

public struct GlassBoard: Reducer {
    
    public struct State: Equatable, Identifiable {
        
        public let id: UUID
        public let frame: NSRect
        public let drawingData: [DrawingData] = []
        
        public init(id: UUID, frame: NSRect) {
            self.id = id
            self.frame = frame
        }
    }
    
    public enum Action {
        
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
            case .delegate:
                return .none
            }
        }
    }
}
