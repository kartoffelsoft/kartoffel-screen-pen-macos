import AppKit
import Combine
import ComposableArchitecture

@MainActor
public class EventTapController {

    private let store: StoreOf<EventTap>
    private let viewStore: ViewStoreOf<EventTap>
    private var cancellables: Set<AnyCancellable> = []
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private var eventsOfInterests: CGEventMask = {
        var mask: CGEventMask = 0
        mask |= (1 << CGEventType.keyDown.rawValue)
        mask |= (1 << CGEventType.keyUp.rawValue)
        mask |= (1 << CGEventType.mouseMoved.rawValue)
        mask |= (1 << CGEventType.leftMouseDown.rawValue)
        mask |= (1 << CGEventType.leftMouseDragged.rawValue)
        mask |= (1 << CGEventType.leftMouseUp.rawValue)
        mask |= (1 << CGEventType.rightMouseDown.rawValue)
        mask |= (1 << CGEventType.rightMouseDragged.rawValue)
        mask |= (1 << CGEventType.rightMouseUp.rawValue)
        return mask
    }()
    
    public init(store: StoreOf<EventTap>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewStore.publisher.isActive.sink { [weak self] isActive in
            guard let self = self else { return }
            
            self.cleanup()
            
            if isActive {
                self.eventTap = CGEvent.tapCreate(
                    tap: .cgSessionEventTap,
                    place: .headInsertEventTap,
                    options: .defaultTap,
                    eventsOfInterest: self.eventsOfInterests,
                    callback: Self.eventTapCallBack,
                    userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                )
                
                guard let eventTap = eventTap else { return }
                
                runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
                
                CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
        }
        .store(in: &self.cancellables)
    }
    
    private func cleanup() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
    }
    
    static let eventTapCallBack: CGEventTapCallBack = { proxy, type, event, userInfo in
        guard let userInfo = userInfo else { return Unmanaged.passRetained(event) }

        let weakSelf = Unmanaged<EventTapController>.fromOpaque(userInfo).takeUnretainedValue()
        
        switch type {
        case .keyDown:
            if event.getIntegerValueField(.keyboardEventKeycode) == 53 {
                weakSelf.viewStore.send(.delegate(.escKeyDown))
            }
            return nil
            
        case .mouseMoved:
            weakSelf.viewStore.send(.delegate(.mouseMoved(event.location)))
            return nil
            
        case .leftMouseDown:
            weakSelf.viewStore.send(.delegate(.leftMouseDown(event.location)))
            return nil
            
        case .leftMouseDragged:
            weakSelf.viewStore.send(.delegate(.leftMouseDragged(event.location)))
            return nil
            
        case .leftMouseUp:
            weakSelf.viewStore.send(.delegate(.leftMouseUp(event.location)))
            return nil

        case .keyUp: fallthrough
        case .rightMouseDown: fallthrough
        case .rightMouseDragged: fallthrough
        case .rightMouseUp: return nil
            
        default:
            break
        }
        
        return Unmanaged.passRetained(event)
    }
}
