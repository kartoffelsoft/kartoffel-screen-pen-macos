import AppKit
import Combine
import ComposableArchitecture

@MainActor
public class MenuController: NSObject {

    private let store: StoreOf<Menu>
    private let viewStore: ViewStoreOf<Menu>
    
    private let statusBarItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )

    private var cancellables: Set<AnyCancellable> = []
    
    public init(store: StoreOf<Menu>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        super.init()
        setupBindings()
    }
    
    public func load() {
        let mainMenu = NSMenu()
        mainMenu.delegate = self
        
        mainMenu.addItem(NSMenuItem.separator())
        
        let quit = NSMenuItem(
            title: "Quit Screen Pen",
            action: #selector(NSApp.terminate(_:)),
            keyEquivalent: ""
        )
        
        mainMenu.addItem(quit)

        statusBarItem.menu = mainMenu
        statusBarItem.button?.image = NSImage(
            systemSymbolName: "applepencil.and.scribble",
            accessibilityDescription: nil
        )
    }
    
    private func setupBindings() {
    }
}

extension MenuController: NSMenuDelegate {
    
    public func menuWillOpen(_ menu: NSMenu) {
        viewStore.send(.start)
    }
}
