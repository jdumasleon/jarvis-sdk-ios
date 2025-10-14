import SwiftUI

/// Navigation layer for the Jarvis SDK
/// Handles routing, navigation coordination, and deep linking
public struct JarvisNavigation {
    public static let version = "1.0.0"
}

// MARK: - Navigation Destinations

/// Navigation destinations within Jarvis
public enum JarvisDestination: Hashable {
    case home
    case inspector
    case inspectorDetail(requestId: String)
    case preferences
    case settings
    case about
}

// MARK: - Navigation Coordinator

/// Coordinates navigation throughout the Jarvis SDK
@MainActor
public class JarvisNavigationCoordinator: ObservableObject {
    @Published public var navigationPath = NavigationPath()
    @Published public var selectedTab: String = "home"

    public init() {}

    /// Navigate to a specific destination
    public func navigate(to destination: JarvisDestination) {
        switch destination {
        case .home:
            selectedTab = "home"
            navigationPath = NavigationPath()
        case .inspector:
            selectedTab = "inspector"
            navigationPath = NavigationPath()
        case .inspectorDetail(let requestId):
            selectedTab = "inspector"
            navigationPath.append(JarvisDestination.inspectorDetail(requestId: requestId))
        case .preferences:
            selectedTab = "preferences"
            navigationPath = NavigationPath()
        case .settings:
            selectedTab = "settings"
            navigationPath = NavigationPath()
        case .about:
            navigationPath.append(destination)
        }
    }

    /// Go back in navigation
    public func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    /// Reset navigation to root
    public func resetToRoot() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Navigation Extensions

public extension View {
    /// Apply Jarvis navigation styling
    func jarvisNavigation() -> some View {
        #if os(iOS)
        self
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        #else
        self
        #endif
    }
}