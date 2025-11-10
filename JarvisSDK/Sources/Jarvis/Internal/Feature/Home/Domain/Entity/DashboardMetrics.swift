//
//  DashboardMetrics.swift
//  JarvisSDK
//
//  Combined dashboard metrics wrapper
//

import Foundation

/// Basic dashboard metrics (legacy)
public struct DashboardMetrics: Codable, Equatable {
    public let networkMetrics: NetworkMetrics
    public let preferencesMetrics: PreferencesMetrics
    public let performanceMetrics: PerformanceMetrics

    public init(
        networkMetrics: NetworkMetrics,
        preferencesMetrics: PreferencesMetrics,
        performanceMetrics: PerformanceMetrics
    ) {
        self.networkMetrics = networkMetrics
        self.preferencesMetrics = preferencesMetrics
        self.performanceMetrics = performanceMetrics
    }
}

/// Basic network metrics
public struct NetworkMetrics: Codable, Equatable {
    public let totalCalls: Int
    public let averageSpeed: Double
    public let successfulCalls: Int
    public let failedCalls: Int
    public let successRate: Double

    public init(
        totalCalls: Int,
        averageSpeed: Double,
        successfulCalls: Int,
        failedCalls: Int,
        successRate: Double
    ) {
        self.totalCalls = totalCalls
        self.averageSpeed = averageSpeed
        self.successfulCalls = successfulCalls
        self.failedCalls = failedCalls
        self.successRate = successRate
    }
}

/// Basic preferences metrics
public struct PreferencesMetrics: Codable, Equatable {
    public let totalPreferences: Int
    public let preferencesByType: [String: Int]
    public let mostCommonType: String?

    public init(
        totalPreferences: Int,
        preferencesByType: [String: Int],
        mostCommonType: String?
    ) {
        self.totalPreferences = totalPreferences
        self.preferencesByType = preferencesByType
        self.mostCommonType = mostCommonType
    }
}

/// Basic performance metrics
public struct PerformanceMetrics: Codable, Equatable {
    public let rating: PerformanceRating
    public let averageResponseTime: Double
    public let errorRate: Double
    public let apdexScore: Double

    public init(
        rating: PerformanceRating,
        averageResponseTime: Double,
        errorRate: Double,
        apdexScore: Double
    ) {
        self.rating = rating
        self.averageResponseTime = averageResponseTime
        self.errorRate = errorRate
        self.apdexScore = apdexScore
    }
}

/// Performance rating
public enum PerformanceRating: String, Codable, Equatable {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case average = "AVERAGE"
    case poor = "POOR"
    case critical = "CRITICAL"
}

/// Enhanced dashboard metrics with advanced analytics
public struct EnhancedDashboardMetrics: Codable, Equatable {
    // Legacy metrics for backward compatibility
    public let networkMetrics: NetworkMetrics
    public let preferencesMetrics: PreferencesMetrics
    public let performanceMetrics: PerformanceMetrics

    // Enhanced metrics
    public let healthScore: HealthScore?
    public let enhancedNetworkMetrics: EnhancedNetworkMetrics
    public let enhancedPreferencesMetrics: EnhancedPreferencesMetrics

    // System performance monitoring (CPU, Memory, FPS)
    public let performanceSnapshot: PerformanceSnapshot?

    // Session info
    public let sessionInfo: SessionInfo?
    public let lastUpdated: Date

    public init(
        networkMetrics: NetworkMetrics,
        preferencesMetrics: PreferencesMetrics,
        performanceMetrics: PerformanceMetrics,
        healthScore: HealthScore?,
        enhancedNetworkMetrics: EnhancedNetworkMetrics,
        enhancedPreferencesMetrics: EnhancedPreferencesMetrics,
        performanceSnapshot: PerformanceSnapshot? = nil,
        sessionInfo: SessionInfo?,
        lastUpdated: Date = Date()
    ) {
        self.networkMetrics = networkMetrics
        self.preferencesMetrics = preferencesMetrics
        self.performanceMetrics = performanceMetrics
        self.healthScore = healthScore
        self.enhancedNetworkMetrics = enhancedNetworkMetrics
        self.enhancedPreferencesMetrics = enhancedPreferencesMetrics
        self.performanceSnapshot = performanceSnapshot
        self.sessionInfo = sessionInfo
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Mock Data

public extension EnhancedDashboardMetrics {
    static var mock: EnhancedDashboardMetrics {
        EnhancedDashboardMetrics(
            networkMetrics: NetworkMetrics(
                totalCalls: 247,
                averageSpeed: 156.8,
                successfulCalls: 231,
                failedCalls: 16,
                successRate: 93.5
            ),
            preferencesMetrics: PreferencesMetrics(
                totalPreferences: 42,
                preferencesByType: [
                    "SHARED_PREFERENCES": 25,
                    "DATASTORE": 12,
                    "PROTO": 5
                ],
                mostCommonType: "SHARED_PREFERENCES"
            ),
            performanceMetrics: PerformanceMetrics(
                rating: .good,
                averageResponseTime: 156.8,
                errorRate: 6.5,
                apdexScore: 0.85
            ),
            healthScore: .mock,
            enhancedNetworkMetrics: .mock,
            enhancedPreferencesMetrics: .mock,
            performanceSnapshot: .mock,
            sessionInfo: SessionInfo(
                sessionId: "session_\(Date().timeIntervalSince1970)",
                startTime: Date().addingTimeInterval(-3600),
                endTime: nil
            ),
            lastUpdated: Date()
        )
    }
}
