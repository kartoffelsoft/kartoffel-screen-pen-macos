import AppRootFeature
import Cocoa
import ComposableArchitecture

class AppDelegate: NSObject, NSApplicationDelegate {

    private let store = Store(initialState: AppRoot.State()) {
        AppRoot()
    }
    
    private var viewStore: ViewStore<AppRoot.State, AppRoot.Action> {
        ViewStore(self.store, observe: { $0 })
    }
    
    private var controller: AppRootController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        controller = AppRootController(store: store)
        viewStore.send(.appRootDelegate(.didFinishLaunching))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
