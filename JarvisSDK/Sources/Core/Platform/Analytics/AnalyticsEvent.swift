import Foundation

/// Analytics event for tracking user interactions
public struct AnalyticsEvent {
    public let name: String
    public let properties: [String: Any]
    public let timestamp: TimeInterval
    public let userId: String?
    public let sessionId: String?

    public init(
        name: String,
        properties: [String: Any] = [:],
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        userId: String? = nil,
        sessionId: String? = nil
    ) {
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
        self.userId = userId
        self.sessionId = sessionId
    }
}
