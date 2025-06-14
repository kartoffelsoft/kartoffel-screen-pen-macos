import AppKit
import ApplicationServices
import ColorPickerFeature
import Combine
import ComposableArchitecture
import HotKeyFeature
import StyleGuide

@MainActor
public class MenuController: NSObject {

    private let store: StoreOf<Menu>
    private let viewStore: ViewStoreOf<Menu>
    private var cancellables: Set<AnyCancellable> = []
    
    private let colorPickerView: ColorPickerView
    private let hotKeyController: HotKeyController
    private let statusBarItem = NSStatusBar.system.statusItem(withLength: 20)

    private let mainMenu = NSMenu()
    
    public init(store: StoreOf<Menu>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        self.colorPickerView = .init(store: self.store.scope(
            state: \.colorPicker,
            action: Menu.Action.colorPicker
        ))
        
        self.hotKeyController = .init(store: self.store.scope(
            state: \.hotKey,
            action: Menu.Action.hotKey
        ))
        
        super.init()
        
        setupMenu()
        setupBindings()
    }
    
    private func setupMenu() {
        mainMenu.delegate = self

        statusBarItem.menu = mainMenu
        statusBarItem.menu?.delegate = self
        statusBarItem.button?.image = .theme.appIcon
        statusBarItem.button?.image?.size = NSSize(width: 16, height: 16)
        statusBarItem.button?.image?.isTemplate = true
    }
    
    private func setupBindings() {        
        viewStore.publisher.openMenuSignal.sink { [weak self] signal in
            guard let _ = signal else { return }
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.statusBarItem.button?.performClick(self)
            }
        }
        .store(in: &self.cancellables)
    }
    
    private func buildMainMenu() {
        mainMenu.removeAllItems()
        
        if AXIsProcessTrusted() {
            let pen = NSMenuItem(
                title: "Pen",
                action: #selector(handlePenClick),
                keyEquivalent: "p"
            )
            pen.target = self
            mainMenu.addItem(pen)

            let laserPointer = NSMenuItem(
                title: "Laser Pointer",
                action: #selector(handleLaserPointerClick),
                keyEquivalent: "l"
            )
            laserPointer.target = self
            mainMenu.addItem(laserPointer)
            
            let eraser = NSMenuItem(
                title: "Eraser",
                action: #selector(handleEraserClick),
                keyEquivalent: "e"
            )
            eraser.target = self
            mainMenu.addItem(eraser)
            
            mainMenu.addItem(NSMenuItem.separator())
            
            let colorPicker = NSMenuItem()
            colorPicker.view = colorPickerView
            mainMenu.addItem(colorPicker)

            mainMenu.addItem(NSMenuItem.separator())
            
            let help = NSMenuItem(
                title: "Keyboard Shortcuts Help",
                action: #selector(handleHelpClick),
                keyEquivalent: ""
            )
            help.target = self
            mainMenu.addItem(help)
            
            let settings = NSMenuItem(
                title: "Settings...",
                action: #selector(handleSettingsClick),
                keyEquivalent: ""
            )
            settings.target = self
            mainMenu.addItem(settings)
            
        } else {
            let permission = NSMenuItem(
                title: "⚠️ Allow Access in Settings...",
                action: #selector(handlePermissionClick),
                keyEquivalent: ""
            )
            permission.target = self
            mainMenu.addItem(permission)
        }

        mainMenu.addItem(NSMenuItem.separator())
        
        let quit = NSMenuItem(
            title: "Quit ScreenPen",
            action: #selector(NSApp.terminate(_:)),
            keyEquivalent: "q"
        )
        mainMenu.addItem(quit)
    }
    
    @objc private func handlePenClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectDrawingTool(.pen(color: .clear))))
    }
    
    @objc private func handleLaserPointerClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectDrawingTool(.laserPointer(color: .clear))))
    }
    
    @objc private func handleEraserClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.selectDrawingTool(.eraser)))
    }

    @objc private func handleHelpClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.openHelp))
    }
    
    @objc private func handleSettingsClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.openSettings))
    }
    
    @objc private func handlePermissionClick(_ sender: NSMenuItem) {
        viewStore.send(.delegate(.openPermission))
    }
}

extension MenuController: NSMenuDelegate {
    
    public func menuWillOpen(_ menu: NSMenu) {
        viewStore.send(.deactivateHotKey)
        
        buildMainMenu()
        
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x7D, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x7D, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
    
    public func menuDidClose(_ menu: NSMenu) {
        viewStore.send(.activateHotKey)
    }
}
