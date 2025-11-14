import Foundation
#if canImport(Sentry)
import Sentry
#endif

/// Sentry implementation of CrashReporter
/// Requires Sentry SDK to be added to Package.swift dependencies
public final class SentryCrashReporter: CrashReporter {

    // MARK: - Properties

    private let dsn: String

    // MARK: - Initialization

    public init(dsn: String) {
        self.dsn = dsn
    }

    // MARK: - CrashReporter Protocol

    public func initialize() async {
        #if canImport(Sentry)
        SentrySDK.start { options in
            options.dsn = self.dsn
            options.debug = true
            options.enableAutoSessionTracking = true
            options.sessionTrackingIntervalMillis = 30000

            // Set up SDK-specific configuration
            options.beforeSend = { event in
                event.tags?["sdk"] = "jarvis-ios"
                event.tags?["version"] = "1.0.0"
                event.tags?["platform"] = "ios"
                return event
            }
        }
        print("[SentryCrashReporter] Initialized with DSN: \(dsn)")
        #else
        print("[SentryCrashReporter] Warning: Sentry SDK not available. Add 'Sentry' to Package.swift dependencies.")
        #endif
    }

    public func recordException(_ throwable: Error, tags: [String: String] = [:]) async {
        #if canImport(Sentry)
        SentrySDK.configureScope { scope in
            tags.forEach { key, value in
                scope.setTag(value: value, key: key)
            }
        }
        SentrySDK.capture(error: throwable)
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Exception not recorded: \(throwable.localizedDescription)")
        #endif
    }

    public func log(_ message: String, level: LogLevel = .info) async {
        #if canImport(Sentry)
        let sentryLevel = convertToSentryLevel(level)
        SentrySDK.capture(message: message) { scope in
            scope.setLevel(sentryLevel)
        }
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Log not recorded: \(message)")
        #endif
    }

    public func setUser(userId: String, email: String? = nil, username: String? = nil) async {
        #if canImport(Sentry)
        let user = User(userId: userId)
        user.email = email
        user.username = username
        SentrySDK.setUser(user)
        #else
        print("[SentryCrashReporter] Sentry SDK not available. User not set: \(userId)")
        #endif
    }

    public func setTag(key: String, value: String) async {
        #if canImport(Sentry)
        SentrySDK.configureScope { scope in
            scope.setTag(value: value, key: key)
        }
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Tag not set: \(key)=\(value)")
        #endif
    }

    public func setTags(_ tags: [String: String]) async {
        #if canImport(Sentry)
        SentrySDK.configureScope { scope in
            tags.forEach { key, value in
                scope.setTag(value: value, key: key)
            }
        }
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Tags not set.")
        #endif
    }

    public func addBreadcrumb(
        message: String,
        category: String = "general",
        level: LogLevel = .info
    ) async {
        #if canImport(Sentry)
        let breadcrumb = Breadcrumb()
        breadcrumb.message = message
        breadcrumb.category = category
        breadcrumb.level = convertToSentryLevel(level)
        SentrySDK.addBreadcrumb(breadcrumb)
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Breadcrumb not added: \(message)")
        #endif
    }

    public func setContext(key: String, context: [String: Any]) async {
        #if canImport(Sentry)
        SentrySDK.configureScope { scope in
            scope.setContext(value: context, key: key)
        }
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Context not set: \(key)")
        #endif
    }

    public func setEnabled(_ enabled: Bool) async {
        #if canImport(Sentry)
        if !enabled {
            SentrySDK.close()
        }
        #else
        print("[SentryCrashReporter] Sentry SDK not available. Cannot set enabled state.")
        #endif
    }

    // MARK: - Private Helpers

    #if canImport(Sentry)
    private func convertToSentryLevel(_ level: LogLevel) -> SentryLevel {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        case .fatal:
            return .fatal
        }
    }
    #endif
}
