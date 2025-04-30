import AppKit
import AppKitUtils
import Combine
import ComposableArchitecture
import GlassBoardFeature
import StyleGuide

@MainActor
public class AppRootController {

    private let store: StoreOf<AppRoot>
    private let viewStore: ViewStoreOf<AppRoot>
    private var cancellables: Set<AnyCancellable> = []
    
    private var glassBoardWindowControllers: IdentifiedArrayOf<GlassBoardWindowController> = []
    private let menuController: MenuController

    private var cursor: NSCursor?

    public init(store: StoreOf<AppRoot>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        self.menuController = .init(store: self.store.scope(
            state: \.menu,
            action: AppRoot.Action.menu
        ))
        
        self.menuController.load()
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewStore.publisher.createGlassBoards.sink { [weak self] data in
            guard data.isValid else { return }
            guard let self = self else { return }
            self.viewStore.send(.createGlassBoards(NSScreen.screens.map{$0.frame}))
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.showGlassBoards.sink { [weak self] data in
            guard let self = self else { return }
            guard data.count > 0 else {
                self.glassBoardWindowControllers.forEach { $0.window?.close() }
                self.glassBoardWindowControllers.removeAll()
                return
            }
            
            NSApp.activate(ignoringOtherApps: true)

            data.forEach { id in
                let controller = GlassBoardWindowController(id: id)
                
                controller.contentViewController = IfLetStoreController(store: self.store.scope(
                    state: { $0.glassBoards[id: id] },
                    action: { .glassBoards(id: id, action: $0) }
                )) {
                    GlassBoardViewController(store: $0)
                } else: {
                    NSViewController()
                }
                
                controller.showWindow(self)
                self.glassBoardWindowControllers.append(controller)
            }
        }
        .store(in: &self.cancellables)
        
        viewStore.publisher.stationery.sink { [weak self] data in
            guard let self = self else { return }
            
            switch(data) {
            case let .pen(color: color):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    
                    if self.cursor == nil {
                        if let image = NSImage(systemSymbolName: "hand.point.up.left.fill", accessibilityDescription: nil) {
                            image.size = NSSize(width: 32, height: 32)
                            self.cursor = NSCursor(image: image, hotSpot: NSPoint(x: 16, y: 16))
                        }
                    }
                    self.cursor?.set()
                }
                break
                
            case .laserPointer:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }

                    if self.cursor == nil {
                        let image = NSImage.theme.laserPointerCursor
                        image.size = NSSize(width: 20, height: 20)
                        self.cursor = NSCursor(image: image, hotSpot: NSPoint(x: 10, y: 10))
                    }
                    self.cursor?.set()
                }
                break
                
            case .eraser:
                break
                
            case .none:
                cursor = nil
                NSCursor.arrow.set()
                break
            }
        }
        .store(in: &self.cancellables)
    }
}
