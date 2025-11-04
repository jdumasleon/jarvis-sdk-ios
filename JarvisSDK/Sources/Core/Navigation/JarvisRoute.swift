//
//  JarvisRoute.swift
//  JarvisSDK
//
//  Navigation routes for Jarvis SDK
//

import SwiftUI

/// Represents all possible navigation routes in Jarvis SDK
public enum JarvisRoute: Hashable {
    case home
    case inspector
    case preferences
    case settings
    case logging

    /// Get the title for the route
    public var title: String {
        switch self {
        case .home:
            return "Home"
        case .inspector:
            return "Inspector"
        case .preferences:
            return "Preferences"
        case .settings:
            return "Settings"
        case .logging:
            return "Logging"
        }
    }
}
