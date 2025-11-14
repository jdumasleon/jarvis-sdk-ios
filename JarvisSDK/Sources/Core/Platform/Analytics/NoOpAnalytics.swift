import Foundation

/// No-op implementation of Analytics
/// Used when analytics is disabled or keys are not configured
public final class NoOpAnalytics: Analytics {

    // MARK: - Initialization

    public init() {}

    // MARK: - Analytics Protocol

    public func track(event: AnalyticsEvent) async {
        // No-op
    }

    public func track(eventName: String, properties: [String: Any]) async {
        // No-op
    }

    public func identify(userProfile: UserProfile) async {
        // No-op
    }

    public func setUserProperties(userProfile: UserProfile, properties: [String: Any]) async {
        // No-op
    }

    public func setEnabled(_ enabled: Bool) async {
        // No-op
    }

    public func reset() async {
        // No-op
    }

    public func flush() async {
        // No-op
    }
}
