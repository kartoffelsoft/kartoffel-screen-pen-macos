
public struct Signal: Equatable {

    private var count: UInt8
    
    public init(count: UInt8 = 0) {
        self.count = count
    }
    
    public mutating func fire() {
        count = (count == UInt8.max) ? 1 : count + 1
    }
    
    public var isValid: Bool {
        return self.count != 0
    }
}
