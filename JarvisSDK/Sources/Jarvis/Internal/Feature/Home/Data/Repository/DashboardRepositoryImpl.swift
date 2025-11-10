//
//  DashboardRepositoryImpl.swift
//  JarvisSDK
//
//  Implementation of DashboardRepository combining network and preferences data
//

import Foundation
import Combine
import JarvisInspectorDomain
import JarvisPreferencesDomain

/// Implementation of DashboardRepository
public final class DashboardRepositoryImpl: DashboardRepository {

    private let networkRepository: NetworkTransactionRepositoryProtocol
    private let preferencesRepository: PreferenceRepositoryProtocol
    private let basicMapper: DashboardMetricsMapper
    private let enhancedMapper: EnhancedDashboardMetricsMapper
    private let performanceMonitor: PerformanceMonitorManager

    // Cache to reduce computation
    private var cachedMetrics: EnhancedDashboardMetrics?
    private var cacheTimestamp: Date?
    private let cacheInterval: TimeInterval = 5.0 // 5 seconds
    private var cachedSessionFilter: SessionFilter?

    init(
        networkRepository: NetworkTransactionRepositoryProtocol,
        preferencesRepository: PreferenceRepositoryProtocol,
        basicMapper: DashboardMetricsMapper,
        enhancedMapper: EnhancedDashboardMetricsMapper,
        performanceMonitor: PerformanceMonitorManager
    ) {
        self.networkRepository = networkRepository
        self.preferencesRepository = preferencesRepository
        self.basicMapper = basicMapper
        self.enhancedMapper = enhancedMapper
        self.performanceMonitor = performanceMonitor
    }

    // MARK: - DashboardRepository

    public func getDashboardMetrics() -> AnyPublisher<DashboardMetrics, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DashboardError.repositoryDeallocated))
                return
            }

            Task {
                do {
                    let transactions = try await self.networkRepository.fetchRecent(limit: 200)
                    let preferences = self.preferencesRepository.scanAllPreferences()

                    let metrics = self.basicMapper.mapToDashboardMetrics(
                        transactions: transactions,
                        preferences: preferences
                    )

                    promise(.success(metrics))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func getEnhancedDashboardMetrics(sessionFilter: SessionFilter) -> AnyPublisher<EnhancedDashboardMetrics, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DashboardError.repositoryDeallocated))
                return
            }

            Task {
                // Check cache
                if let cached = self.cachedMetrics,
                   let cacheTime = self.cacheTimestamp,
                   let cachedFilter = self.cachedSessionFilter,
                   Date().timeIntervalSince(cacheTime) < self.cacheInterval,
                   cachedFilter == sessionFilter {
                    promise(.success(cached))
                    return
                }

                do {
                    // Fetch data (limit to 200 most recent transactions for performance)
                    let transactions = try await self.networkRepository.fetchRecent(limit: 200)
                    let preferences = self.preferencesRepository.scanAllPreferences()

                    // Map to enhanced metrics
                    var metrics = self.enhancedMapper.mapToEnhancedDashboardMetrics(
                        networkTransactions: transactions,
                        preferences: preferences,
                        sessionFilter: sessionFilter
                    )

                    // Get current performance snapshot from monitor
                    let performanceSnapshot = self.performanceMonitor.currentSnapshot

                    // Inject performance data into metrics
                    metrics = EnhancedDashboardMetrics(
                        networkMetrics: metrics.networkMetrics,
                        preferencesMetrics: metrics.preferencesMetrics,
                        performanceMetrics: metrics.performanceMetrics,
                        healthScore: metrics.healthScore,
                        enhancedNetworkMetrics: metrics.enhancedNetworkMetrics,
                        enhancedPreferencesMetrics: metrics.enhancedPreferencesMetrics,
                        performanceSnapshot: performanceSnapshot,
                        sessionInfo: metrics.sessionInfo,
                        lastUpdated: metrics.lastUpdated
                    )

                    // Update cache
                    self.cachedMetrics = metrics
                    self.cacheTimestamp = Date()
                    self.cachedSessionFilter = sessionFilter

                    promise(.success(metrics))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func refreshMetrics() async throws -> DashboardMetrics {
        // Clear cache on refresh
        cachedMetrics = nil
        cacheTimestamp = nil
        cachedSessionFilter = nil

        // Fetch fresh data
        let transactions = try await networkRepository.fetchRecent(limit: 200)
        let preferences = preferencesRepository.scanAllPreferences()

        return basicMapper.mapToDashboardMetrics(
            transactions: transactions,
            preferences: preferences
        )
    }
}

// MARK: - Errors

enum DashboardError: Error {
    case repositoryDeallocated
}
