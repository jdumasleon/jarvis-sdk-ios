//
//  InspectorDI.swift
//  JarvisSDK
//
//  Dependency injection configuration for Inspector module
//

import Foundation
import JarvisCommon

import JarvisInspectorDomain
import JarvisInspectorData

/// Centralized dependency registration for Inspector feature module
@MainActor
public struct InspectorDependencyRegistration {

    /// Register all Inspector module dependencies
    public static func register(container: DependencyContainer = .shared) {
        registerRepositories(container: container)
        registerUseCases(container: container)
    }

    // MARK: - Private Registration Methods

    private static func registerRepositories(container: DependencyContainer) {
        // Repository (Singleton - shared state across the app)
        container.register(
            NetworkTransactionRepositoryProtocol.self,
            scope: .singleton
        ) {
            NetworkTransactionRepository()
        }
    }

    private static func registerUseCases(container: DependencyContainer) {
        // Monitor Network Transactions Use Case (Transient)
        container.register(
            MonitorNetworkTransactionsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return MonitorNetworkTransactionsUseCase(repository: repository)
        }

        // Get Network Transaction Use Case (Transient)
        container.register(
            GetNetworkTransactionUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return GetNetworkTransactionUseCase(repository: repository)
        }

        // Filter Network Transactions Use Case (Transient)
        container.register(
            FilterNetworkTransactionsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            return FilterNetworkTransactionsUseCase(repository: repository)
        }
    }
}
