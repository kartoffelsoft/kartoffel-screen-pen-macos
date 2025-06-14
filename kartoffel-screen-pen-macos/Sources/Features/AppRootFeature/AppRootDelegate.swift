import ApplicationServices
import ComposableArchitecture
import Foundation

public struct AppRootDelegate: Reducer {
    
    public struct State: Equatable {
        
        var axTrustedCheckOptions: NSDictionary = [:]
    }
    
    public enum Action {
        
        case didFinishLaunching(NSDictionary)
        case openPermission
        
        case delegate(DelegateAction)
        
        public enum DelegateAction: Equatable {
            
            case start
        }
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .didFinishLaunching(axTrustedCheckOptions):
                state.axTrustedCheckOptions = axTrustedCheckOptions
                return .run { send in
                    await send(.openPermission)
                    await send(.delegate(.start))
                }
                
            case .openPermission:
                AXIsProcessTrustedWithOptions(state.axTrustedCheckOptions)
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
