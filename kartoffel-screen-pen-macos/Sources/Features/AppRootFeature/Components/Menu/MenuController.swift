import AppKit
import Combine
import ComposableArchitecture
import StyleGuide

@MainActor
public class MenuController: NSObject {

    private let store: StoreOf<Menu>
    private let viewStore: ViewStoreOf<Menu>
    
    private let statusBarItem = NSStatusBar.system.statusItem(
        withLength: 20
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

        let laserPointer = NSMenuItem(
            title: "Laser Pointer",
            action: #selector(handleLaserPointerClick),
            keyEquivalent: ""
        )
        laserPointer.target = self
        mainMenu.addItem(laserPointer)
        
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
        statusBarItem.button?.image = .theme.appIcon
        statusBarItem.button?.image?.size = NSSize(width: 16, height: 16)
        statusBarItem.button?.image?.isTemplate = true
    }
    
    private func setupBindings() {
    }

    @objc private func handlePenClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectPen))
    }
    
    @objc private func handleLaserPointerClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectLaserPointer))
    }
    
    @objc private func handleClearClick(_ sender: NSMenuItem) {

    }
}

extension MenuController: NSMenuDelegate {
    
    public func menuWillOpen(_ menu: NSMenu) {
        viewStore.send(.start)
    }
}
