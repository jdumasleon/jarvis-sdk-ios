//
//  SettingsDI.swift
//  JarvisSDK
//
//  Dependency injection configuration for Settings module
//

import Foundation
import Common

/// Centralized dependency registration for Settings feature module
@MainActor
public struct SettingsDependencyRegistration {

    /// Register all Settings module dependencies
    public static func register(container: DependencyContainer = .shared) {
        registerProviders(container: container)
        registerApiServices(container: container)
        registerRepositories(container: container)
        registerUseCases(container: container)
    }

    // MARK: - Private Registration Methods

    private static func registerProviders(container: DependencyContainer) {
        // App Info Provider (Singleton)
        container.register(
            AppInfoProvider.self,
            scope: .singleton
        ) {
            AppInfoProvider()
        }
    }

    private static func registerApiServices(container: DependencyContainer) {
        // Rating API Service (Singleton)
        container.register(
            RatingApiService.self,
            scope: .singleton
        ) {
            RatingApiServiceImpl()
        }
    }

    private static func registerRepositories(container: DependencyContainer) {
        // Settings Repository (Singleton)
        container.register(
            SettingsRepositoryProtocol.self,
            scope: .singleton
        ) {
            let provider = container.resolve(AppInfoProvider.self)
            return SettingsRepository(appInfoProvider: provider)
        }

        // Rating Repository (Singleton)
        container.register(
            RatingRepository.self,
            scope: .singleton
        ) {
            let apiService = container.resolve(RatingApiService.self)
            return RatingRepositoryImpl(ratingApiService: apiService)
        }
    }

    private static func registerUseCases(container: DependencyContainer) {
        // Get Settings Items Use Case (Transient)
        container.register(
            GetSettingsItemsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(SettingsRepositoryProtocol.self)
            return GetSettingsItemsUseCase(repository: repository)
        }

        // Submit Rating Use Case (Transient)
        container.register(
            SubmitRatingUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(RatingRepository.self)
            return SubmitRatingUseCase(ratingRepository: repository)
        }
    }
}
