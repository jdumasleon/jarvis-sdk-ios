//
//  HomeDI.swift
//  JarvisSDK
//
//  Dependency injection configuration for Home module
//

import Foundation
import JarvisCommon
import JarvisInspectorDomain
import JarvisPreferencesDomain

/// Centralized dependency registration for Home feature module
@MainActor
public struct HomeDependencyRegistration {

    /// Register all Home module dependencies
    public static func register(container: DependencyContainer = .shared) {
        registerAnalyzers(container: container)
        registerMappers(container: container)
        registerRepositories(container: container)
        registerUseCases(container: container)
    }

    // MARK: - Private Registration Methods

    private static func registerAnalyzers(container: DependencyContainer) {
        // Health Score Calculator (Singleton - shared logic)
        container.register(
            HealthScoreCalculator.self,
            scope: .singleton
        ) {
            HealthScoreCalculator()
        }

        // Network Analyzer (Singleton - shared logic)
        container.register(
            NetworkAnalyzer.self,
            scope: .singleton
        ) {
            NetworkAnalyzer()
        }

        // Preferences Analyzer (Singleton - shared logic)
        container.register(
            PreferencesAnalyzer.self,
            scope: .singleton
        ) {
            PreferencesAnalyzer()
        }
    }

    private static func registerMappers(container: DependencyContainer) {
        // Basic Dashboard Metrics Mapper (Singleton - shared logic)
        container.register(
            DashboardMetricsMapper.self,
            scope: .singleton
        ) {
            DashboardMetricsMapper()
        }

        // Enhanced Dashboard Metrics Mapper (Singleton - shared logic)
        container.register(
            EnhancedDashboardMetricsMapper.self,
            scope: .singleton
        ) {
            let healthCalculator = container.resolve(HealthScoreCalculator.self)
            let networkAnalyzer = container.resolve(NetworkAnalyzer.self)
            let preferencesAnalyzer = container.resolve(PreferencesAnalyzer.self)
            let basicMapper = container.resolve(DashboardMetricsMapper.self)

            return EnhancedDashboardMetricsMapper(
                basicMapper: basicMapper,
                healthScoreCalculator: healthCalculator,
                networkAnalyzer: networkAnalyzer,
                preferencesAnalyzer: preferencesAnalyzer
            )
        }
    }

    private static func registerRepositories(container: DependencyContainer) {
        // Dashboard Repository (Singleton - shared state across the app)
        container.register(
            DashboardRepository.self,
            scope: .singleton
        ) {
            let networkRepository = container.resolve(NetworkTransactionRepositoryProtocol.self)
            let preferencesRepository = container.resolve(PreferenceRepositoryProtocol.self)
            let basicMapper = container.resolve(DashboardMetricsMapper.self)
            let enhancedMapper = container.resolve(EnhancedDashboardMetricsMapper.self)

            return DashboardRepositoryImpl(
                networkRepository: networkRepository,
                preferencesRepository: preferencesRepository,
                basicMapper: basicMapper,
                enhancedMapper: enhancedMapper,
                performanceMonitor: JarvisSDK.shared.performanceMonitor
            )
        }
    }

    private static func registerUseCases(container: DependencyContainer) {
        // Get Dashboard Metrics Use Case (Transient)
        container.register(
            GetDashboardMetricsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(DashboardRepository.self)
            return GetDashboardMetricsUseCase(repository: repository)
        }

        // Get Enhanced Dashboard Metrics Use Case (Transient)
        container.register(
            GetEnhancedDashboardMetricsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(DashboardRepository.self)
            return GetEnhancedDashboardMetricsUseCase(repository: repository)
        }

        // Refresh Dashboard Metrics Use Case (Transient)
        container.register(
            RefreshDashboardMetricsUseCase.self,
            scope: .transient
        ) {
            let repository = container.resolve(DashboardRepository.self)
            return RefreshDashboardMetricsUseCase(repository: repository)
        }
    }
}
