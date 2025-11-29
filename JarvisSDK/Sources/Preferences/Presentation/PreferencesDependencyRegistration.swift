//
//  PreferencesDI.swift
//  JarvisSDK
//
//  Dependency injection configuration for Preferences module
//

import Foundation
import JarvisCommon
import JarvisPreferencesDomain
import JarvisPreferencesData
import JarvisPreferencesPresentation

/// Centralized dependency registration for Preferences feature module
@MainActor
public struct PreferencesDependencyRegistration {

    /// Register all Preferences module dependencies
    public static func register(container: DependencyContainer = .shared) {
        registerRepositories(container: container)
        registerUseCases(container: container)
    }

    // MARK: - Private Registration Methods

    private static func registerRepositories(container: DependencyContainer) {
        // Repository (Singleton - shared state across the app)
        container.register(
            PreferenceRepositoryProtocol.self,
            scope: .singleton
        ) {
            PreferenceRepository()
        }
    }

    private static func registerUseCases(container: DependencyContainer) {
        // Get Preferences Use Case (Transient - new instance each time)
        container.register(
            GetPreferencesUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return GetPreferencesUseCase(repository: repository)
        }

        // Update Preference Use Case (Transient)
        container.register(
            UpdatePreferenceUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return UpdatePreferenceUseCase(repository: repository)
        }

        // Delete Preference Use Case (Transient)
        container.register(
            DeletePreferenceUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return DeletePreferenceUseCase(repository: repository)
        }
    }
}
