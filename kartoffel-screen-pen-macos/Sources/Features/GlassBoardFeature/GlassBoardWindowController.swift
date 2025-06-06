import Cocoa
import ComposableArchitecture

public class GlassBoardWindowController: NSWindowController, Identifiable {
    
    public let id: UInt32

    public init(id: UInt32) {
        self.id = id
        super.init(window: GlassBoardWindow())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
