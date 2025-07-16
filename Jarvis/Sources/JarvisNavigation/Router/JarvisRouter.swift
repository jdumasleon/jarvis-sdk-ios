import SwiftUI
import Combine

public final class JarvisRouter: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var presentedSheet: JarvisDestination?
    @Published public var presentedFullScreen: JarvisDestination?
    
    public init() {}
    
    public func navigate(to destination: JarvisDestination) {
        path.append(destination)
    }
    
    public func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    public func navigateToRoot() {
        path = NavigationPath()
    }
    
    public func presentSheet(_ destination: JarvisDestination) {
        presentedSheet = destination
    }
    
    public func presentFullScreen(_ destination: JarvisDestination) {
        presentedFullScreen = destination
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func dismissFullScreen() {
        presentedFullScreen = nil
    }
}

public enum JarvisDestination: Hashable, Identifiable {
    case networkInspector
    case preferencesInspector
    case requestDetail(id: UUID)
    case preferenceEditor(key: String)
    
    public var id: String {
        switch self {
        case .networkInspector:
            return "networkInspector"
        case .preferencesInspector:
            return "preferencesInspector"
        case .requestDetail(let id):
            return "requestDetail-\(id.uuidString)"
        case .preferenceEditor(let key):
            return "preferenceEditor-\(key)"
        }
    }
}