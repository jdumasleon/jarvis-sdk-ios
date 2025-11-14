import Foundation
#if canImport(PostHog)
import PostHog
#endif

/// PostHog implementation of Analytics
/// Requires PostHog SDK to be added to Package.swift dependencies
public final class PostHogAnalytics: Analytics {

    // MARK: - Properties

    private var isInitialized = false
    private let apiKey: String
    private let host: String

    // MARK: - Initialization

    public init(apiKey: String, host: String = "https://us.i.posthog.com") {
        self.apiKey = apiKey
        self.host = host
    }

    // MARK: - Analytics Protocol

    public func track(event: AnalyticsEvent) async {
        ensureInitialized()

        #if canImport(PostHog)
        var properties = event.properties
        properties["timestamp"] = event.timestamp
        if let userId = event.userId {
            properties["user_id"] = userId
        }
        if let sessionId = event.sessionId {
            properties["session_id"] = sessionId
        }

        PostHogSDK.shared.capture(
            event.name,
            properties: properties
        )
        #else
        print("[PostHogAnalytics] PostHog SDK not available. Event '\(event.name)' not tracked.")
        #endif
    }

    public func track(eventName: String, properties: [String: Any] = [:]) async {
        ensureInitialized()

        #if canImport(PostHog)
        PostHogSDK.shared.capture(eventName, properties: properties)
        #else
        print("[PostHogAnalytics] PostHog SDK not available. Event '\(eventName)' not tracked.")
        #endif
    }

    public func identify(userProfile: UserProfile) async {
        ensureInitialized()

        #if canImport(PostHog)
        var properties = userProfile.properties
        if let email = userProfile.email {
            properties["email"] = email
        }
        if let name = userProfile.name {
            properties["name"] = name
        }

        PostHogSDK.shared.identify(
            userProfile.userId,
            userProperties: properties
        )
        #else
        print("[PostHogAnalytics] PostHog SDK not available. User '\(userProfile.userId)' not identified.")
        #endif
    }

    public func setUserProperties(userProfile: UserProfile, properties: [String: Any]) async {
        ensureInitialized()

        #if canImport(PostHog)
        PostHogSDK.shared.identify(
            userProfile.userId,
            userProperties: properties
        )
        #else
        print("[PostHogAnalytics] PostHog SDK not available. User properties not set.")
        #endif
    }

    public func setEnabled(_ enabled: Bool) async {
        ensureInitialized()

        #if canImport(PostHog)
        if enabled {
            PostHogSDK.shared.optIn()
        } else {
            PostHogSDK.shared.optOut()
        }
        #else
        print("[PostHogAnalytics] PostHog SDK not available. Cannot set enabled state.")
        #endif
    }

    public func reset() async {
        ensureInitialized()

        #if canImport(PostHog)
        PostHogSDK.shared.reset()
        #else
        print("[PostHogAnalytics] PostHog SDK not available. Cannot reset.")
        #endif
    }

    public func flush() async {
        ensureInitialized()

        #if canImport(PostHog)
        PostHogSDK.shared.flush()
        #else
        print("[PostHogAnalytics] PostHog SDK not available. Cannot flush.")
        #endif
    }

    // MARK: - Private Methods

    private func ensureInitialized() {
        guard !isInitialized else { return }

        #if canImport(PostHog)
        let config = PostHogConfig(apiKey: apiKey, host: host)
        config.debug = true
        config.captureApplicationLifecycleEvents = true
        config.captureScreenViews = true

        PostHogSDK.shared.setup(config)
        isInitialized = true
        print("[PostHogAnalytics] Initialized with host: \(host)")
        #else
        print("[PostHogAnalytics] Warning: PostHog SDK not available. Add 'PostHog' to Package.swift dependencies.")
        #endif
    }
}
