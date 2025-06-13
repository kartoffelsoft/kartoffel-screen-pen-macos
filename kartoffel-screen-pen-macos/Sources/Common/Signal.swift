import Foundation

public struct Signal<T>: Equatable {

    public let value: T?
    
    private let token: UUID
    
    public init() {
        self.token = UUID()
        self.value = nil
    }
    
    public init(_ value: T) {
        self.token = UUID()
        self.value = value
    }
    
    public static func == (lhs: Signal<T>, rhs: Signal<T>) -> Bool {
        lhs.token == rhs.token
    }
}
