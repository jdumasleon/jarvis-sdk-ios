//
//  EnhancedDashboardMetricsMapper.swift
//  JarvisSDK
//
//  Maps raw data to enhanced dashboard metrics using analyzers
//

import Foundation
import JarvisDomain
import JarvisPreferencesDomain

/// Mapper for enhanced dashboard metrics with advanced analytics
public final class EnhancedDashboardMetricsMapper {

    private let basicMapper: DashboardMetricsMapper
    private let healthScoreCalculator: HealthScoreCalculator
    private let networkAnalyzer: NetworkAnalyzer
    private let preferencesAnalyzer: PreferencesAnalyzer

    public init(
        basicMapper: DashboardMetricsMapper,
        healthScoreCalculator: HealthScoreCalculator,
        networkAnalyzer: NetworkAnalyzer,
        preferencesAnalyzer: PreferencesAnalyzer
    ) {
        self.basicMapper = basicMapper
        self.healthScoreCalculator = healthScoreCalculator
        self.networkAnalyzer = networkAnalyzer
        self.preferencesAnalyzer = preferencesAnalyzer
    }

    /// Map network transactions and preferences to enhanced dashboard metrics
    public func mapToEnhancedDashboardMetrics(
        networkTransactions: [NetworkTransaction],
        preferences: [Preference],
        sessionFilter: SessionFilter
    ) -> EnhancedDashboardMetrics {

        // Filter data based on session
        let filteredTransactions = filterTransactions(networkTransactions, sessionFilter: sessionFilter)
        let filteredPreferences = preferences // Preferences are current state, include all

        // Generate basic metrics for backward compatibility
        let basicMetrics = basicMapper.mapToDashboardMetrics(
            transactions: filteredTransactions,
            preferences: filteredPreferences
        )

        // Generate enhanced analytics
        let healthScore = healthScoreCalculator.calculateHealthScore(
            transactions: filteredTransactions,
            preferences: filteredPreferences
        )

        let enhancedNetworkMetrics = networkAnalyzer.analyzeNetworkMetrics(
            transactions: filteredTransactions,
            sessionFilter: sessionFilter
        )

        let enhancedPreferencesMetrics = preferencesAnalyzer.analyzePreferencesMetrics(
            preferences: filteredPreferences,
            sessionFilter: sessionFilter
        )

        // Create session info
        let sessionInfo = getCurrentSessionInfo(transactions: filteredTransactions)

        return EnhancedDashboardMetrics(
            networkMetrics: basicMetrics.networkMetrics,
            preferencesMetrics: basicMetrics.preferencesMetrics,
            performanceMetrics: basicMetrics.performanceMetrics,
            healthScore: healthScore,
            enhancedNetworkMetrics: enhancedNetworkMetrics,
            enhancedPreferencesMetrics: enhancedPreferencesMetrics,
            sessionInfo: sessionInfo,
            lastUpdated: Date()
        )
    }

    // MARK: - Session Filtering

    private func filterTransactions(
        _ transactions: [NetworkTransaction],
        sessionFilter: SessionFilter
    ) -> [NetworkTransaction] {

        switch sessionFilter {
        case .lastSession:
            return filterLastSession(transactions)
        case .last24Hours:
            return filterLast24Hours(transactions)
        }
    }

    private func filterLastSession(_ transactions: [NetworkTransaction]) -> [NetworkTransaction] {
        guard !transactions.isEmpty else { return [] }

        // Consider the last hour as the current session
        let sessionStartTime = Date().addingTimeInterval(-3600) // 1 hour ago

        return transactions.filter { $0.startTime >= sessionStartTime }
    }

    private func filterLast24Hours(_ transactions: [NetworkTransaction]) -> [NetworkTransaction] {
        guard !transactions.isEmpty else { return [] }

        // Filter for last 24 hours
        let last24HoursTime = Date().addingTimeInterval(-86400) // 24 hours ago

        return transactions.filter { $0.startTime >= last24HoursTime }
    }

    // MARK: - Session Info

    private func getCurrentSessionInfo(transactions: [NetworkTransaction]) -> SessionInfo? {
        guard !transactions.isEmpty else { return nil }

        let sessionStartTime = transactions.map { $0.startTime }.min() ?? Date()
        let sessionId = "session_\(Int(sessionStartTime.timeIntervalSince1970))"

        return SessionInfo(
            sessionId: sessionId,
            startTime: sessionStartTime,
            endTime: nil // Current session is ongoing
        )
    }
}
