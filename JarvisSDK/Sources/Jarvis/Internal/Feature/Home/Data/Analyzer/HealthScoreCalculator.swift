//
//  HealthScoreCalculator.swift
//  JarvisSDK
//
//  Calculates weighted health score based on network and system metrics
//

import Foundation
import Domain
import JarvisPreferencesDomain

/// Calculates application health score with weighted factors
public final class HealthScoreCalculator {

    // Weights for health score calculation
    private let networkPerformanceWeight: Float = 0.40  // 40%
    private let errorRateWeight: Float = 0.30            // 30%
    private let responseTimeWeight: Float = 0.20         // 20%
    private let systemResourcesWeight: Float = 0.10      // 10%

    public init() {}

    /// Calculate health score from network transactions and preferences
    public func calculateHealthScore(
        transactions: [NetworkTransaction],
        preferences: [Preference]
    ) -> HealthScore {

        guard !transactions.isEmpty else {
            return getDefaultHealthScore()
        }

        // Only count completed transactions (have a response)
        let completedTransactions = transactions.filter { $0.response != nil }

        guard !completedTransactions.isEmpty else {
            return getDefaultHealthScore()
        }

        // Successful: 2xx and 3xx (redirects are successful)
        let successfulTransactions = completedTransactions.filter {
            guard let statusCode = $0.response?.statusCode else { return false }
            return statusCode >= 200 && statusCode < 400
        }

        // Errors: Only 4xx (client errors) and 5xx (server errors)
        let errorTransactions = completedTransactions.filter {
            guard let statusCode = $0.response?.statusCode else { return false }
            return statusCode >= 400
        }

        // Calculate metrics
        let errorRate = Float(errorTransactions.count) / Float(completedTransactions.count) * 100.0

        let averageResponseTime = successfulTransactions
            .compactMap { $0.duration }
            .reduce(0.0, +) / Double(max(successfulTransactions.count, 1))

        // Calculate individual scores
        let networkScore = scoreNetworkPerformance(averageResponseTime: averageResponseTime)
        let errorScore = scoreErrorRate(errorRate: errorRate)
        let responseScore = scoreResponseTime(averageResponseTime: averageResponseTime)
        let resourceScore = scoreSystemResources(preferenceCount: preferences.count)

        // Calculate weighted overall score
        let overallScore = (
            networkScore * networkPerformanceWeight +
            errorScore * errorRateWeight +
            responseScore * responseTimeWeight +
            resourceScore * systemResourcesWeight
        )

        // Determine rating
        let rating = determineRating(score: overallScore)

        // Calculate performance score (combination of network and response)
        let performanceScore = (networkScore + responseScore) / 2.0

        // Calculate uptime (percentage of successful requests)
        let uptime = Float(successfulTransactions.count) / Float(completedTransactions.count) * 100.0

        let keyMetrics = HealthKeyMetrics(
            totalRequests: completedTransactions.count,
            errorRate: errorRate,
            averageResponseTime: Float(averageResponseTime),
            performanceScore: performanceScore,
            networkScore: networkScore,
            uptime: uptime
        )

        return HealthScore(
            overallScore: overallScore,
            rating: rating,
            keyMetrics: keyMetrics,
            lastUpdated: Date()
        )
    }

    // MARK: - Individual Scoring Functions

    private func scoreNetworkPerformance(averageResponseTime: Double) -> Float {
        // Score based on average response time buckets
        switch averageResponseTime {
        case 0..<100: return 100.0
        case 100..<300: return 90.0
        case 300..<500: return 80.0
        case 500..<1000: return 60.0
        case 1000..<2000: return 40.0
        default: return 20.0
        }
    }

    private func scoreErrorRate(errorRate: Float) -> Float {
        // Score based on error rate percentage
        switch errorRate {
        case 0: return 100.0
        case 0..<1: return 95.0
        case 1..<3: return 85.0
        case 3..<5: return 70.0
        case 5..<10: return 50.0
        default: return 20.0
        }
    }

    private func scoreResponseTime(averageResponseTime: Double) -> Float {
        // Score based on response time buckets
        switch averageResponseTime {
        case 0..<100: return 100.0
        case 100..<300: return 90.0
        case 300..<500: return 80.0
        case 500..<1000: return 60.0
        case 1000..<2000: return 40.0
        default: return 20.0
        }
    }

    private func scoreSystemResources(preferenceCount: Int) -> Float {
        // Score based on preference count (proxy for system resource usage)
        switch preferenceCount {
        case 0..<50: return 100.0
        case 50..<100: return 90.0
        case 100..<200: return 80.0
        case 200..<500: return 60.0
        default: return 40.0
        }
    }

    private func determineRating(score: Float) -> HealthRating {
        switch score {
        case 90...100: return .excellent
        case 75..<90: return .good
        case 50..<75: return .average
        case 25..<50: return .poor
        default: return .critical
        }
    }

    private func getDefaultHealthScore() -> HealthScore {
        return HealthScore(
            overallScore: 100.0,
            rating: .excellent,
            keyMetrics: HealthKeyMetrics(
                totalRequests: 0,
                errorRate: 0.0,
                averageResponseTime: 0.0,
                performanceScore: 100.0,
                networkScore: 100.0,
                uptime: 100.0
            ),
            lastUpdated: Date()
        )
    }
}
