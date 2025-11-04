//
//  DependencyConfiguration.swift
//  JarvisSDK
//
//  Centralized dependency registration for the Jarvis SDK
//

import Foundation
import Common
import JarvisPreferencesPresentation
import JarvisPreferencesDomain
import JarvisPreferencesData
import JarvisInspectorPresentation
import JarvisInspectorDomain
import JarvisInspectorData

/// Centralized dependency registration for Jarvis SDK
@MainActor
public struct DependencyConfiguration {

    /// Register all dependencies for the Jarvis SDK
    public static func registerDependencies() {
        registerPreferencesDependencies()
        registerInspectorDependencies()
    }

    // MARK: - Preferences Module Dependencies

    private static func registerPreferencesDependencies() {
        let container = DependencyContainer.shared

        // Register Repository (Singleton - shared across the app)
        container.register(
            PreferenceRepositoryProtocol.self,
            scope: .singleton
        ) {
            PreferenceRepository()
        }

        // Register Use Cases (Transient - new instance each time)
        container.register(
            GetPreferencesUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return GetPreferencesUseCase(repository: repository)
        }

        container.register(
            UpdatePreferenceUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return UpdatePreferenceUseCase(repository: repository)
        }

        container.register(
            DeletePreferenceUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(PreferenceRepositoryProtocol.self)
            return DeletePreferenceUseCase(repository: repository)
        }

        // Register ViewModel (Transient - new instance for each view)
        container.register(
            PreferencesViewModel.self,
            scope: .transient
        ) {
            let getUseCase = container.resolve(GetPreferencesUseCase.self)
            let updateUseCase = container.resolve(UpdatePreferenceUseCase.self)
            let deleteUseCase = container.resolve(DeletePreferenceUseCase.self)
            return PreferencesViewModel(
                getPreferencesUseCase: getUseCase,
                updatePreferenceUseCase: updateUseCase,
                deletePreferenceUseCase: deleteUseCase
            )
        }
    }

    // MARK: - Inspector Module Dependencies

    private static func registerInspectorDependencies() {
        let container = DependencyContainer.shared

        // Register Repository (Singleton)
        container.register(
            NetworkTransactionRepositoryProtocol.self,
            scope: .singleton
        ) {
            NetworkTransactionRepository()
        }

        // Register Use Cases (Transient)
        container.register(
            MonitorNetworkTransactionsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return MonitorNetworkTransactionsUseCase(repository: repository)
        }

        container.register(
            GetNetworkTransactionUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return GetNetworkTransactionUseCase(repository: repository)
        }

        container.register(
            FilterNetworkTransactionsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return FilterNetworkTransactionsUseCase(repository: repository)
        }

        // Register ViewModel (Transient)
        container.register(
            NetworkInspectorViewModel.self,
            scope: .transient
        ) {
            let monitorUseCase = container.resolve(MonitorNetworkTransactionsUseCase.self)
            let getUseCase = container.resolve(GetNetworkTransactionUseCase.self)
            let filterUseCase = container.resolve(FilterNetworkTransactionsUseCase.self)
            return NetworkInspectorViewModel(
                monitorNetworkTransactionsUseCase: monitorUseCase,
                getNetworkTransactionUseCase: getUseCase,
                filterNetworkTransactionsUseCase: filterUseCase
            )
        }
    }

    // MARK: - Cleanup

    /// Clear all registered dependencies (useful for testing)
    public static func clearDependencies() {
        DependencyContainer.shared.clear()
    }
}
