import Foundation

/// Crash reporter protocol for error tracking and monitoring
public protocol CrashReporter {
    /// Initialize the crash reporter
    func initialize() async

    /// Record an exception with optional tags
    func recordException(_ throwable: Error, tags: [String: String]) async

    /// Log a message with a specified level
    func log(_ message: String, level: LogLevel) async

    /// Add user context for crash reports
    func setUser(userId: String, email: String?, username: String?) async

    /// Set a custom tag
    func setTag(key: String, value: String) async

    /// Set multiple tags at once
    func setTags(_ tags: [String: String]) async

    /// Add a breadcrumb for debugging
    func addBreadcrumb(message: String, category: String, level: LogLevel) async

    /// Set custom context
    func setContext(key: String, context: [String: Any]) async

    /// Enable or disable crash reporting
    func setEnabled(_ enabled: Bool) async
}
