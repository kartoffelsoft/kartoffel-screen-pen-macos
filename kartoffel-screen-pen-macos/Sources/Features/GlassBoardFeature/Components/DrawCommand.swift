import Common
import Foundation

public struct DrawingCommand: Equatable {
    
    public var data: Data
    
    private var stamp: Date
    
    public init(_ data: Data) {
        self.data = data
        self.stamp = Date()
    }
}

extension DrawingCommand {
    
    public enum Data: Equatable {

        case clear
        case draw
        case refresh
        case none
    }
}
