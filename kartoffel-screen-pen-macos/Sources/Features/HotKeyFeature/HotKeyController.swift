import Carbon
import Combine
import ComposableArchitecture

@MainActor
public class HotKeyController {

    private let store: StoreOf<HotKey>
    private let viewStore: ViewStoreOf<HotKey>
    private var cancellables: Set<AnyCancellable> = []

    private var eventHotKeyRefs: [EventHotKeyRef] = []
    private var eventHandler: EventHandlerRef?
    
    private let signature: UInt32 = {
        "KTFL".utf16.reduce(FourCharCode(0)) { (r, c) in
            (r << 8) + FourCharCode(c)
        }
    }()
    
    public init(store: StoreOf<HotKey>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        setupBindings()
    }

    private func setupBindings() {
        viewStore.publisher.entries.sink { [weak self] entries in
            guard let self = self else { return }
            
            self.cleanup()
            
            for entry in entries {
                guard let keyCode = entry.keyEquivalent.keyCode else { continue }
                
                var eventHotKeyRef: EventHotKeyRef?
                
                let err = RegisterEventHotKey(
                    UInt32(keyCode),
                    entry.keyEquivalentModifierMask.carbonModifierFlags,
                    EventHotKeyID(signature: OSType(signature), id: UInt32(entry.id)),
                    GetApplicationEventTarget(),
                    0,
                    &eventHotKeyRef
                )
                
                guard err == noErr else { return }
                guard let eventHotKeyRef = eventHotKeyRef else { return }
                        
                eventHotKeyRefs.append(eventHotKeyRef)
                
                InstallEventHandler(
                    GetApplicationEventTarget(),
                    Self.hotKeyEventHandler,
                    2,
                    [
                        EventTypeSpec(
                            eventClass: OSType(kEventClassKeyboard),
                            eventKind: UInt32(kEventHotKeyPressed)
                        ),
                        EventTypeSpec(
                            eventClass: OSType(kEventClassKeyboard),
                            eventKind: UInt32(kEventHotKeyReleased)
                        )
                    ],
                    UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                    &eventHandler
                )
            }
        }
        .store(in: &self.cancellables)
    }

    private func cleanup() {
        for ref in eventHotKeyRefs {
            RemoveEventHandler(ref)
        }
        eventHotKeyRefs.removeAll()
    }
    
    static let hotKeyEventHandler: EventHandlerUPP = { (nextHandler, event, userData) in
        guard let userData = userData, let event = event else {
            return OSStatus(eventNotHandledErr)
        }

        var hotKeyID = EventHotKeyID()
        let err = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout.size(ofValue: hotKeyID),
            nil,
            &hotKeyID
        )
        
        guard err == noErr else { return OSStatus(eventNotHandledErr) }
        
        let weakSelf = Unmanaged<HotKeyController>.fromOpaque(userData).takeUnretainedValue()
        
        guard hotKeyID.signature == weakSelf.signature else {
            return OSStatus(eventNotHandledErr)
        }
            
        switch GetEventKind(event) {
        case UInt32(kEventHotKeyPressed):
            weakSelf.viewStore.send(.delegate(.hotKeyDown(hotKeyID.id)))
            return noErr
            
        case UInt32(kEventHotKeyReleased):
            return noErr
            
        default:
            break
        }
        
        return noErr
    }
}
