import Foundation

/// Analytics service protocol for tracking events and user behavior
public protocol Analytics {
    /// Track an event with detailed information
    func track(event: AnalyticsEvent) async

    /// Track an event with name and properties
    func track(eventName: String, properties: [String: Any]) async

    /// Identify a user with their profile
    func identify(userProfile: UserProfile) async

    /// Set user properties
    func setUserProperties(userProfile: UserProfile, properties: [String: Any]) async

    /// Enable or disable analytics
    func setEnabled(_ enabled: Bool) async

    /// Reset user data
    func reset() async

    /// Flush pending events
    func flush() async
}
