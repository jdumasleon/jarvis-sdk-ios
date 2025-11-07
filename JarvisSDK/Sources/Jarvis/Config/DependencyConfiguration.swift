//
//  JarvisDI.swift
//  JarvisSDK
//
//  Main dependency injection bootstrapper for Jarvis SDK
//  Delegates to individual feature modules for registration
//

import Foundation
import Common
import JarvisInspectorPresentation
import JarvisPreferencesPresentation

/// Main DI bootstrapper that coordinates all feature module registrations
@MainActor
public struct DependencyConfiguration {

    /// Register all dependencies across all feature modules
    public static func registerAll(container: DependencyContainer = .shared) {
        // Register feature modules in dependency order
        // Each module's DI is responsible for its own dependencies

        PreferencesDependencyRegistration.register(container: container)
        InspectorDependencyRegistration.register(container: container)
        HomeDependencyRegistration.register(container: container)
        SettingsDependencyRegistration.register(container: container)

        JarvisLogger.shared.debug("All feature module dependencies registered")
    }

    /// Clear all registered dependencies (useful for testing)
    public static func clearAll(container: DependencyContainer = .shared) {
        container.clear()
        JarvisLogger.shared.debug("All dependencies cleared")
    }
}
