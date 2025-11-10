//
//  HealthScore.swift
//  JarvisSDK
//
//  Overall health score and key metrics
//

import Foundation

/// Overall health score and key metrics for the application
public struct HealthScore: Codable, Equatable {
    public let overallScore: Float      // 0.0 to 100.0
    public let rating: HealthRating
    public let keyMetrics: HealthKeyMetrics
    public let lastUpdated: Date

    public init(
        overallScore: Float,
        rating: HealthRating,
        keyMetrics: HealthKeyMetrics,
        lastUpdated: Date = Date()
    ) {
        self.overallScore = overallScore
        self.rating = rating
        self.keyMetrics = keyMetrics
        self.lastUpdated = lastUpdated
    }
}

/// Health rating categories
public enum HealthRating: String, Codable, Equatable {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case average = "AVERAGE"
    case poor = "POOR"
    case critical = "CRITICAL"

    public var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .average: return "Average"
        case .poor: return "Poor"
        case .critical: return "Critical"
        }
    }

    public var color: String {
        switch self {
        case .excellent: return "#4CAF50"
        case .good: return "#8BC34A"
        case .average: return "#FFC107"
        case .poor: return "#FF9800"
        case .critical: return "#F44336"
        }
    }
}

/// Key health metrics displayed in the summary
public struct HealthKeyMetrics: Codable, Equatable {
    public let totalRequests: Int
    public let errorRate: Float              // Percentage 0.0-100.0
    public let averageResponseTime: Float    // milliseconds
    public let performanceScore: Float       // 0.0-100.0
    public let networkScore: Float           // 0.0-100.0
    public let uptime: Float                 // Percentage 0.0-100.0

    public init(
        totalRequests: Int,
        errorRate: Float,
        averageResponseTime: Float,
        performanceScore: Float,
        networkScore: Float,
        uptime: Float
    ) {
        self.totalRequests = totalRequests
        self.errorRate = errorRate
        self.averageResponseTime = averageResponseTime
        self.performanceScore = performanceScore
        self.networkScore = networkScore
        self.uptime = uptime
    }
}

/// Factors contributing to health score calculation
public struct HealthScoreFactors: Codable, Equatable {
    public let networkPerformance: Float     // Weight: 40%
    public let errorRate: Float              // Weight: 30%
    public let responseTime: Float           // Weight: 20%
    public let systemResources: Float        // Weight: 10%

    public init(
        networkPerformance: Float,
        errorRate: Float,
        responseTime: Float,
        systemResources: Float
    ) {
        self.networkPerformance = networkPerformance
        self.errorRate = errorRate
        self.responseTime = responseTime
        self.systemResources = systemResources
    }
}

// MARK: - Mock Data

public extension HealthScore {
    static var mock: HealthScore {
        HealthScore(
            overallScore: 85.6,
            rating: .good,
            keyMetrics: HealthKeyMetrics(
                totalRequests: 247,
                errorRate: 6.5,
                averageResponseTime: 156.8,
                performanceScore: 82.3,
                networkScore: 88.1,
                uptime: 99.2
            ),
            lastUpdated: Date()
        )
    }
}
