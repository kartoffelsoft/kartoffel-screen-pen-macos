import Cocoa
import ComposableArchitecture

public class GlassBoardWindowController: NSWindowController, Identifiable {
    
    public let id: UUID

    public init(id: UUID) {
        self.id = id
        super.init(window: GlassBoardWindow())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
