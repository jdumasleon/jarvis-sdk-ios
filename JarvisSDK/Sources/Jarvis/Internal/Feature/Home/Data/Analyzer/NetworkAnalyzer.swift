//
//  NetworkAnalyzer.swift
//  JarvisSDK
//
//  Analyzes network transaction data for enhanced metrics and charts
//

import Foundation
import Domain

/// Analyzes network transactions to generate enhanced metrics and chart data
public final class NetworkAnalyzer {

    public init() {}

    /// Analyze network transactions to create enhanced metrics
    public func analyzeNetworkMetrics(
        transactions: [NetworkTransaction],
        sessionFilter: SessionFilter
    ) -> EnhancedNetworkMetrics {

        guard !transactions.isEmpty else {
            return createEmptyMetrics(sessionFilter: sessionFilter)
        }

        // Calculate basic metrics
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

        let averageRequestSize = Int64(transactions
            .map { $0.request.bodySize }
            .reduce(0, +) / max(transactions.count, 1))

        let averageResponseSize = Int64(completedTransactions
            .compactMap { $0.response?.bodySize ?? 0 }
            .reduce(0, +) / max(completedTransactions.count, 1))

        // Generate enhanced analytics
        let requestsOverTime = generateTimeSeriesData(transactions: transactions)
        let httpMethodDistribution = analyzeHttpMethods(transactions: transactions)
        let topEndpoints = analyzeTopEndpoints(transactions: transactions)
        let slowestEndpoints = analyzeSlowestEndpoints(transactions: transactions)
        let statusCodeDistribution = analyzeStatusCodes(transactions: completedTransactions)
        let responseTimeDistribution = analyzeResponseTimeDistribution(transactions: completedTransactions)

        return EnhancedNetworkMetrics(
            totalCalls: totalCalls,
            averageSpeed: averageSpeed,
            successfulCalls: successfulCalls,
            failedCalls: failedCalls,
            successRate: successRate,
            averageRequestSize: averageRequestSize,
            averageResponseSize: averageResponseSize,
            requestsOverTime: requestsOverTime,
            httpMethodDistribution: httpMethodDistribution,
            topEndpoints: topEndpoints,
            slowestEndpoints: slowestEndpoints,
            statusCodeDistribution: statusCodeDistribution,
            responseTimeDistribution: responseTimeDistribution,
            sessionFilter: sessionFilter,
            lastUpdated: Date()
        )
    }

    // MARK: - Time Series Analysis

    private func generateTimeSeriesData(transactions: [NetworkTransaction]) -> [TimeSeriesDataPoint] {
        guard !transactions.isEmpty else { return [] }

        // Group transactions into 1-minute intervals
        let intervalSeconds: TimeInterval = 60 // 1 minute
        let sortedTransactions = transactions.sorted { $0.startTime < $1.startTime }

        guard let firstTime = sortedTransactions.first?.startTime,
              let lastTime = sortedTransactions.last?.startTime else {
            return []
        }

        var dataPoints: [TimeSeriesDataPoint] = []
        var currentTime = firstTime

        while currentTime <= lastTime {
            let nextTime = currentTime.addingTimeInterval(intervalSeconds)

            let count = sortedTransactions.filter {
                $0.startTime >= currentTime && $0.startTime < nextTime
            }.count

            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            let label = formatter.localizedString(for: currentTime, relativeTo: Date())

            dataPoints.append(TimeSeriesDataPoint(
                timestamp: currentTime,
                value: Float(count),
                label: label
            ))

            currentTime = nextTime
        }

        // If we have too many points, downsample
        if dataPoints.count > 20 {
            return downsampleDataPoints(dataPoints, targetCount: 20)
        }

        return dataPoints
    }

    private func downsampleDataPoints(_ points: [TimeSeriesDataPoint], targetCount: Int) -> [TimeSeriesDataPoint] {
        guard points.count > targetCount else { return points }

        let step = Double(points.count) / Double(targetCount)
        var result: [TimeSeriesDataPoint] = []

        for i in 0..<targetCount {
            let index = Int(Double(i) * step)
            if index < points.count {
                result.append(points[index])
            }
        }

        return result
    }

    // MARK: - HTTP Method Analysis

    private func analyzeHttpMethods(transactions: [NetworkTransaction]) -> [HttpMethodData] {
        let grouped = Dictionary(grouping: transactions) { $0.request.method.rawValue }

        let methodData = grouped.map { method, trans -> HttpMethodData in
            let count = trans.count
            let percentage = Float(count) / Float(transactions.count) * 100.0

            let avgResponseTime = trans
                .compactMap { $0.duration }
                .reduce(0.0, +) / Double(max(trans.count, 1))

            return HttpMethodData(
                method: method,
                count: count,
                percentage: percentage,
                averageResponseTime: Float(avgResponseTime * 1000) // Convert to ms
            )
        }

        return methodData.sorted { $0.count > $1.count }
    }

    // MARK: - Endpoint Analysis

    private func analyzeTopEndpoints(transactions: [NetworkTransaction]) -> [EndpointData] {
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            normalizePath(transaction.request.path)
        }

        let endpointData = grouped.compactMap { path, trans -> EndpointData? in
            guard let method = trans.first?.request.method.rawValue else { return nil }

            let count = trans.count
            let avgResponseTime = trans
                .compactMap { $0.duration }
                .reduce(0.0, +) / Double(max(trans.count, 1))

            let errorCount = trans.filter {
                guard let statusCode = $0.response?.statusCode else { return false }
                return statusCode >= 400
            }.count

            let errorRate = Float(errorCount) / Float(count) * 100.0

            let totalTraffic = Int64(trans
                .compactMap { $0.response?.bodySize }
                .reduce(0, +))

            return EndpointData(
                endpoint: path,
                method: method,
                requestCount: count,
                averageResponseTime: Float(avgResponseTime * 1000), // Convert to ms
                errorRate: errorRate,
                totalTraffic: totalTraffic
            )
        }

        return Array(endpointData.sorted { $0.requestCount > $1.requestCount }.prefix(10))
    }

    private func analyzeSlowestEndpoints(transactions: [NetworkTransaction]) -> [SlowEndpointData] {
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            normalizePath(transaction.request.path)
        }

        let slowEndpoints = grouped.compactMap { path, trans -> SlowEndpointData? in
            guard let method = trans.first?.request.method.rawValue else { return nil }

            let durations = trans.compactMap { $0.duration }
            guard !durations.isEmpty else { return nil }

            let avgResponseTime = durations.reduce(0.0, +) / Double(durations.count)

            // Only include if average is > 1 second
            guard avgResponseTime > 1.0 else { return nil }

            let p95 = calculatePercentile(durations, percentile: 0.95)

            let lastSlowRequest = trans
                .filter { ($0.duration ?? 0) > 1.0 }
                .max { $0.startTime < $1.startTime }?.startTime ?? Date()

            return SlowEndpointData(
                endpoint: path,
                method: method,
                averageResponseTime: Float(avgResponseTime * 1000), // Convert to ms
                p95ResponseTime: Float(p95 * 1000), // Convert to ms
                requestCount: trans.count,
                lastSlowRequest: lastSlowRequest
            )
        }

        return Array(slowEndpoints.sorted { $0.averageResponseTime > $1.averageResponseTime }.prefix(10))
    }

    // MARK: - Status Code Analysis

    private func analyzeStatusCodes(transactions: [NetworkTransaction]) -> [Int: Int] {
        var distribution: [Int: Int] = [:]

        for transaction in transactions {
            guard let statusCode = transaction.response?.statusCode else { continue }
            distribution[statusCode, default: 0] += 1
        }

        return distribution
    }

    // MARK: - Response Time Distribution

    private func analyzeResponseTimeDistribution(transactions: [NetworkTransaction]) -> ResponseTimeDistribution {
        let durations = transactions.compactMap { $0.duration }

        var under100ms = 0
        var under500ms = 0
        var under1s = 0
        var under5s = 0
        var over5s = 0

        for duration in durations {
            let ms = duration * 1000
            switch ms {
            case 0..<100: under100ms += 1
            case 100..<500: under500ms += 1
            case 500..<1000: under1s += 1
            case 1000..<5000: under5s += 1
            default: over5s += 1
            }
        }

        return ResponseTimeDistribution(
            under100ms: under100ms,
            under500ms: under500ms,
            under1s: under1s,
            under5s: under5s,
            over5s: over5s
        )
    }

    // MARK: - Helper Functions

    private func normalizePath(_ path: String) -> String {
        // Replace numeric IDs with {id}
        var normalized = path.replacingOccurrences(
            of: "/\\d+",
            with: "/{id}",
            options: .regularExpression
        )

        // Replace UUIDs with {id}
        let uuidPattern = "/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        normalized = normalized.replacingOccurrences(
            of: uuidPattern,
            with: "/{id}",
            options: .regularExpression
        )

        return normalized
    }

    private func calculatePercentile(_ values: [TimeInterval], percentile: Double) -> TimeInterval {
        guard !values.isEmpty else { return 0 }

        let sorted = values.sorted()
        let index = Int(ceil(percentile * Double(sorted.count))) - 1
        let clampedIndex = max(0, min(index, sorted.count - 1))

        return sorted[clampedIndex]
    }

    private func createEmptyMetrics(sessionFilter: SessionFilter) -> EnhancedNetworkMetrics {
        return EnhancedNetworkMetrics(
            totalCalls: 0,
            averageSpeed: 0,
            successfulCalls: 0,
            failedCalls: 0,
            successRate: 0,
            averageRequestSize: 0,
            averageResponseSize: 0,
            requestsOverTime: [],
            httpMethodDistribution: [],
            topEndpoints: [],
            slowestEndpoints: [],
            statusCodeDistribution: [:],
            responseTimeDistribution: ResponseTimeDistribution(
                under100ms: 0,
                under500ms: 0,
                under1s: 0,
                under5s: 0,
                over5s: 0
            ),
            sessionFilter: sessionFilter,
            lastUpdated: Date()
        )
    }
}
