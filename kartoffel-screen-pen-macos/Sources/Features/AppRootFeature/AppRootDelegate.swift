import ApplicationServices
import ComposableArchitecture
import Foundation

public struct AppRootDelegate: Reducer {
    
    public struct State: Equatable {
        
        var axTrustedCheckOptions: NSDictionary = [:]
    }
    
    public enum Action {
        
        case didFinishLaunching(NSDictionary)
        
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
                AXIsProcessTrustedWithOptions(axTrustedCheckOptions)
                
                return .run { send in
                    await send(.delegate(.start))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
