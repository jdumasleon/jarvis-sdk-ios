import Foundation

/// No-op implementation of CrashReporter
/// Used when crash reporting is disabled or DSN is not configured
public final class NoOpCrashReporter: CrashReporter {

    // MARK: - Initialization

    public init() {}

    // MARK: - CrashReporter Protocol

    public func initialize() async {
        // No-op
    }

    public func recordException(_ throwable: Error, tags: [String: String]) async {
        // No-op
    }

    public func log(_ message: String, level: LogLevel) async {
        // No-op
    }

    public func setUser(userId: String, email: String?, username: String?) async {
        // No-op
    }

    public func setTag(key: String, value: String) async {
        // No-op
    }

    public func setTags(_ tags: [String: String]) async {
        // No-op
    }

    public func addBreadcrumb(message: String, category: String, level: LogLevel) async {
        // No-op
    }

    public func setContext(key: String, context: [String: Any]) async {
        // No-op
    }

    public func setEnabled(_ enabled: Bool) async {
        // No-op
    }
}
