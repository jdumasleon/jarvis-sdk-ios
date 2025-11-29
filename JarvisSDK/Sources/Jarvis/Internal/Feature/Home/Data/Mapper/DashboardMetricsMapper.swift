//
//  DashboardMetricsMapper.swift
//  JarvisSDK
//
//  Maps raw network transactions and preferences to basic dashboard metrics
//

import Foundation
import JarvisDomain
import JarvisPreferencesDomain

/// Maps raw data to basic dashboard metrics
public final class DashboardMetricsMapper {

    public init() {}

    /// Map network transactions and preferences to basic dashboard metrics
    public func mapToDashboardMetrics(
        transactions: [NetworkTransaction],
        preferences: [Preference]
    ) -> DashboardMetrics {

        let networkMetrics = mapNetworkMetrics(transactions: transactions)
        let preferencesMetrics = mapPreferencesMetrics(preferences: preferences)
        let performanceMetrics = mapPerformanceMetrics(transactions: transactions)

        return DashboardMetrics(
            networkMetrics: networkMetrics,
            preferencesMetrics: preferencesMetrics,
            performanceMetrics: performanceMetrics
        )
    }

    // MARK: - Network Metrics

    private func mapNetworkMetrics(transactions: [NetworkTransaction]) -> NetworkMetrics {
        let totalCalls = transactions.count
        let completedTransactions = transactions.filter { $0.response != nil }

        let successfulCalls = completedTransactions.filter {
            guard let statusCode = $0.response?.statusCode else { return false }
            return statusCode >= 200 && statusCode < 400
        }.count

        let failedCalls = totalCalls - successfulCalls
        let successRate = totalCalls > 0 ? Double(successfulCalls) / Double(totalCalls) * 100.0 : 0.0

        let averageSpeed = completedTransactions
            .compactMap { $0.duration }
            .reduce(0.0, +) / Double(max(completedTransactions.count, 1))

        return NetworkMetrics(
            totalCalls: totalCalls,
            averageSpeed: averageSpeed,
            successfulCalls: successfulCalls,
            failedCalls: failedCalls,
            successRate: successRate
        )
    }

    // MARK: - Preferences Metrics

    private func mapPreferencesMetrics(preferences: [Preference]) -> PreferencesMetrics {
        let totalPreferences = preferences.count

        let preferencesByType = Dictionary(grouping: preferences) { $0.type }
            .mapValues { $0.count }

        let mostCommonType = preferencesByType.max { $0.value < $1.value }?.key

        return PreferencesMetrics(
            totalPreferences: totalPreferences,
            preferencesByType: preferencesByType,
            mostCommonType: mostCommonType
        )
    }

    // MARK: - Performance Metrics

    private func mapPerformanceMetrics(transactions: [NetworkTransaction]) -> PerformanceMetrics {
        guard !transactions.isEmpty else {
            return PerformanceMetrics(
                rating: .excellent,
                averageResponseTime: 0.0,
                errorRate: 0.0,
                apdexScore: 1.0
            )
        }

        let completedTransactions = transactions.filter { $0.response != nil }

        let successfulTransactions = completedTransactions.filter {
            guard let statusCode = $0.response?.statusCode else { return false }
            return statusCode >= 200 && statusCode < 400
        }

        let errorTransactions = completedTransactions.filter {
            guard let statusCode = $0.response?.statusCode else { return false }
            return statusCode >= 400
        }

        // Calculate error rate
        let errorRate = completedTransactions.isEmpty
            ? 0.0
            : Double(errorTransactions.count) / Double(completedTransactions.count) * 100.0

        // Calculate average response time
        let averageResponseTime = successfulTransactions
            .compactMap { $0.duration }
            .reduce(0.0, +) / Double(max(successfulTransactions.count, 1))

        // Calculate Apdex score
        let apdexScore = calculateApdex(transactions: successfulTransactions, threshold: 1.0)

        // Determine performance rating
        let rating = determinePerformanceRating(errorRate: errorRate, apdexScore: apdexScore)

        return PerformanceMetrics(
            rating: rating,
            averageResponseTime: averageResponseTime,
            errorRate: errorRate,
            apdexScore: apdexScore
        )
    }

    // MARK: - Apdex Calculation

    /// Calculate Apdex (Application Performance Index) score
    /// - Parameters:
    ///   - transactions: Successful transactions
    ///   - threshold: Threshold in seconds (T) - default 1.0 second
    /// - Returns: Apdex score between 0.0 and 1.0
    ///
    /// Apdex formula: (Satisfied + Tolerated/2) / Total
    /// - Satisfied: duration <= T
    /// - Tolerated: T < duration <= 4T
    /// - Frustrated: duration > 4T
    private func calculateApdex(transactions: [NetworkTransaction], threshold: Double) -> Double {
        guard !transactions.isEmpty else { return 1.0 }

        let durations = transactions.compactMap { $0.duration }
        guard !durations.isEmpty else { return 1.0 }

        let satisfied = durations.filter { $0 <= threshold }.count
        let tolerated = durations.filter { $0 > threshold && $0 <= (threshold * 4) }.count

        let apdex = (Double(satisfied) + Double(tolerated) / 2.0) / Double(durations.count)

        return apdex
    }

    // MARK: - Performance Rating

    private func determinePerformanceRating(errorRate: Double, apdexScore: Double) -> PerformanceRating {
        // High error rate = poor performance
        if errorRate > 10.0 {
            return .critical
        } else if errorRate > 5.0 {
            return .poor
        }

        // Use Apdex score for rating
        switch apdexScore {
        case 0.94...1.0: return .excellent
        case 0.85..<0.94: return .good
        case 0.70..<0.85: return .average
        case 0.50..<0.70: return .poor
        default: return .critical
        }
    }

    // MARK: - Statistical Functions

    /// Calculate percentile from a list of values using linear interpolation
    public func calculatePercentile(_ values: [Double], percentile: Double) -> Double {
        guard !values.isEmpty else { return 0.0 }
        guard percentile >= 0 && percentile <= 1.0 else { return 0.0 }

        let sorted = values.sorted()

        if sorted.count == 1 {
            return sorted[0]
        }

        let rank = percentile * Double(sorted.count - 1)
        let lowerIndex = Int(floor(rank))
        let upperIndex = Int(ceil(rank))

        if lowerIndex == upperIndex {
            return sorted[lowerIndex]
        }

        let lowerValue = sorted[lowerIndex]
        let upperValue = sorted[upperIndex]
        let fraction = rank - Double(lowerIndex)

        return lowerValue + (upperValue - lowerValue) * fraction
    }

    /// Calculate multiple percentiles
    public func calculatePercentiles(_ values: [Double]) -> (p50: Double, p90: Double, p95: Double, p99: Double) {
        return (
            p50: calculatePercentile(values, percentile: 0.50),
            p90: calculatePercentile(values, percentile: 0.90),
            p95: calculatePercentile(values, percentile: 0.95),
            p99: calculatePercentile(values, percentile: 0.99)
        )
    }
}
