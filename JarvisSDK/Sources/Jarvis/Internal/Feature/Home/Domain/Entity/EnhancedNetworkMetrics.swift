//
//  EnhancedNetworkMetrics.swift
//  JarvisSDK
//
//  Enhanced network metrics with detailed analytics and chart data
//

import Foundation

/// Enhanced network metrics with detailed analytics and chart data
public struct EnhancedNetworkMetrics: Codable, Equatable {
    // Basic metrics
    public let totalCalls: Int
    public let averageSpeed: Double
    public let successfulCalls: Int
    public let failedCalls: Int
    public let successRate: Double
    public let averageRequestSize: Int64
    public let averageResponseSize: Int64

    // Enhanced analytics for charts
    public let requestsOverTime: [TimeSeriesDataPoint]
    public let httpMethodDistribution: [HttpMethodData]
    public let topEndpoints: [EndpointData]
    public let slowestEndpoints: [SlowEndpointData]
    public let statusCodeDistribution: [Int: Int]
    public let responseTimeDistribution: ResponseTimeDistribution

    // Session filtering
    public let sessionFilter: SessionFilter
    public let lastUpdated: Date

    public init(
        totalCalls: Int,
        averageSpeed: Double,
        successfulCalls: Int,
        failedCalls: Int,
        successRate: Double,
        averageRequestSize: Int64,
        averageResponseSize: Int64,
        requestsOverTime: [TimeSeriesDataPoint],
        httpMethodDistribution: [HttpMethodData],
        topEndpoints: [EndpointData],
        slowestEndpoints: [SlowEndpointData],
        statusCodeDistribution: [Int: Int],
        responseTimeDistribution: ResponseTimeDistribution,
        sessionFilter: SessionFilter,
        lastUpdated: Date = Date()
    ) {
        self.totalCalls = totalCalls
        self.averageSpeed = averageSpeed
        self.successfulCalls = successfulCalls
        self.failedCalls = failedCalls
        self.successRate = successRate
        self.averageRequestSize = averageRequestSize
        self.averageResponseSize = averageResponseSize
        self.requestsOverTime = requestsOverTime
        self.httpMethodDistribution = httpMethodDistribution
        self.topEndpoints = topEndpoints
        self.slowestEndpoints = slowestEndpoints
        self.statusCodeDistribution = statusCodeDistribution
        self.responseTimeDistribution = responseTimeDistribution
        self.sessionFilter = sessionFilter
        self.lastUpdated = lastUpdated
    }
}

/// Time series data point for requests over time chart
public struct TimeSeriesDataPoint: Codable, Equatable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let value: Float
    public let label: String?

    public init(id: UUID = UUID(), timestamp: Date, value: Float, label: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.value = value
        self.label = label
    }
}

/// HTTP method distribution data for donut chart
public struct HttpMethodData: Codable, Equatable, Identifiable {
    public let id: UUID
    public let method: String              // GET, POST, PUT, DELETE, etc.
    public let count: Int
    public let percentage: Float
    public let averageResponseTime: Float
    public let color: String

    public init(
        id: UUID = UUID(),
        method: String,
        count: Int,
        percentage: Float,
        averageResponseTime: Float,
        color: String? = nil
    ) {
        self.id = id
        self.method = method
        self.count = count
        self.percentage = percentage
        self.averageResponseTime = averageResponseTime
        self.color = color ?? Self.getMethodColor(method)
    }

    public static func getMethodColor(_ method: String) -> String {
        switch method.uppercased() {
        case "GET": return "#4CAF50"
        case "POST": return "#2196F3"
        case "PUT": return "#FF9800"
        case "DELETE": return "#F44336"
        case "PATCH": return "#9C27B0"
        default: return "#607D8B"
        }
    }
}

/// Endpoint performance data for bar chart
public struct EndpointData: Codable, Equatable, Identifiable {
    public let id: UUID
    public let endpoint: String
    public let method: String
    public let requestCount: Int
    public let averageResponseTime: Float
    public let errorRate: Float
    public let totalTraffic: Int64           // bytes

    public init(
        id: UUID = UUID(),
        endpoint: String,
        method: String,
        requestCount: Int,
        averageResponseTime: Float,
        errorRate: Float,
        totalTraffic: Int64
    ) {
        self.id = id
        self.endpoint = endpoint
        self.method = method
        self.requestCount = requestCount
        self.averageResponseTime = averageResponseTime
        self.errorRate = errorRate
        self.totalTraffic = totalTraffic
    }
}

/// Slowest endpoint data for performance insights
public struct SlowEndpointData: Codable, Equatable, Identifiable {
    public let id: UUID
    public let endpoint: String
    public let method: String
    public let averageResponseTime: Float
    public let p95ResponseTime: Float
    public let requestCount: Int
    public let lastSlowRequest: Date        // timestamp

    public init(
        id: UUID = UUID(),
        endpoint: String,
        method: String,
        averageResponseTime: Float,
        p95ResponseTime: Float,
        requestCount: Int,
        lastSlowRequest: Date
    ) {
        self.id = id
        self.endpoint = endpoint
        self.method = method
        self.averageResponseTime = averageResponseTime
        self.p95ResponseTime = p95ResponseTime
        self.requestCount = requestCount
        self.lastSlowRequest = lastSlowRequest
    }
}

/// Response time distribution for performance analysis
public struct ResponseTimeDistribution: Codable, Equatable {
    public let under100ms: Int
    public let under500ms: Int
    public let under1s: Int
    public let under5s: Int
    public let over5s: Int

    public var total: Int {
        under100ms + under500ms + under1s + under5s + over5s
    }

    public var percentages: ResponseTimePercentages {
        guard total > 0 else {
            return ResponseTimePercentages(
                under100ms: 0,
                under500ms: 0,
                under1s: 0,
                under5s: 0,
                over5s: 0
            )
        }
        return ResponseTimePercentages(
            under100ms: Float(under100ms) / Float(total) * 100,
            under500ms: Float(under500ms) / Float(total) * 100,
            under1s: Float(under1s) / Float(total) * 100,
            under5s: Float(under5s) / Float(total) * 100,
            over5s: Float(over5s) / Float(total) * 100
        )
    }

    public init(
        under100ms: Int,
        under500ms: Int,
        under1s: Int,
        under5s: Int,
        over5s: Int
    ) {
        self.under100ms = under100ms
        self.under500ms = under500ms
        self.under1s = under1s
        self.under5s = under5s
        self.over5s = over5s
    }
}

/// Response time percentages for display
public struct ResponseTimePercentages: Codable, Equatable {
    public let under100ms: Float
    public let under500ms: Float
    public let under1s: Float
    public let under5s: Float
    public let over5s: Float

    public init(
        under100ms: Float,
        under500ms: Float,
        under1s: Float,
        under5s: Float,
        over5s: Float
    ) {
        self.under100ms = under100ms
        self.under500ms = under500ms
        self.under1s = under1s
        self.under5s = under5s
        self.over5s = over5s
    }
}

// MARK: - Mock Data

public extension EnhancedNetworkMetrics {
    static var mock: EnhancedNetworkMetrics {
        let now = Date()
        return EnhancedNetworkMetrics(
            totalCalls: 247,
            averageSpeed: 156.8,
            successfulCalls: 231,
            failedCalls: 16,
            successRate: 93.5,
            averageRequestSize: 2048,
            averageResponseSize: 4096,
            requestsOverTime: [
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-3600), value: 45, label: "1h ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-1800), value: 67, label: "30m ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-900), value: 52, label: "15m ago"),
                TimeSeriesDataPoint(timestamp: now.addingTimeInterval(-300), value: 73, label: "5m ago"),
                TimeSeriesDataPoint(timestamp: now, value: 82, label: "now")
            ],
            httpMethodDistribution: [
                HttpMethodData(method: "GET", count: 156, percentage: 63.2, averageResponseTime: 120.5),
                HttpMethodData(method: "POST", count: 62, percentage: 25.1, averageResponseTime: 245.3),
                HttpMethodData(method: "PUT", count: 18, percentage: 7.3, averageResponseTime: 189.7),
                HttpMethodData(method: "DELETE", count: 11, percentage: 4.4, averageResponseTime: 98.2)
            ],
            topEndpoints: [
                EndpointData(endpoint: "/api/users", method: "GET", requestCount: 89, averageResponseTime: 125.3, errorRate: 2.1, totalTraffic: 512000),
                EndpointData(endpoint: "/api/auth", method: "POST", requestCount: 45, averageResponseTime: 234.7, errorRate: 0.8, totalTraffic: 256000),
                EndpointData(endpoint: "/api/dashboard", method: "GET", requestCount: 38, averageResponseTime: 156.2, errorRate: 5.2, totalTraffic: 384000),
                EndpointData(endpoint: "/api/profile", method: "PUT", requestCount: 23, averageResponseTime: 189.5, errorRate: 3.1, totalTraffic: 128000)
            ],
            slowestEndpoints: [
                SlowEndpointData(endpoint: "/api/reports", method: "GET", averageResponseTime: 2850.3, p95ResponseTime: 3200.1, requestCount: 12, lastSlowRequest: now.addingTimeInterval(-180)),
                SlowEndpointData(endpoint: "/api/upload", method: "POST", averageResponseTime: 1834.7, p95ResponseTime: 2100.4, requestCount: 8, lastSlowRequest: now.addingTimeInterval(-300)),
                SlowEndpointData(endpoint: "/api/analytics", method: "GET", averageResponseTime: 1245.2, p95ResponseTime: 1500.8, requestCount: 15, lastSlowRequest: now.addingTimeInterval(-120))
            ],
            statusCodeDistribution: [
                200: 189,
                201: 34,
                400: 8,
                401: 3,
                404: 6,
                500: 7
            ],
            responseTimeDistribution: ResponseTimeDistribution(
                under100ms: 89,
                under500ms: 124,
                under1s: 18,
                under5s: 12,
                over5s: 4
            ),
            sessionFilter: .lastSession,
            lastUpdated: now
        )
    }
}
