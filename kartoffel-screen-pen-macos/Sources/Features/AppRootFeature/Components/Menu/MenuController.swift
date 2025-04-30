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

        let pen = NSMenuItem(
            title: "Pen",
            action: #selector(handlePenClick),
            keyEquivalent: ""
        )
        pen.target = self
        mainMenu.addItem(pen)

        let clear = NSMenuItem(
            title: "Erase All",
            action: #selector(handleClearClick),
            keyEquivalent: ""
        )
        clear.target = self
        mainMenu.addItem(clear)
        
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

    @objc private func handlePenClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectPen))
    }
    
    @objc private func handleClearClick(_ sender: NSMenuItem) {

    }
}

extension MenuController: NSMenuDelegate {
    
    public func menuWillOpen(_ menu: NSMenu) {
        viewStore.send(.start)
    }
}
