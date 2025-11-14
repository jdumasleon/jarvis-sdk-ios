//
//  JarvisPlatform.swift
//  Platform
//
//  Platform layer for the Jarvis SDK
//

import Foundation

/// Main platform service providing access to all platform services
/// Coordinates analytics, crash reporting, and other platform integrations
public final class JarvisPlatform {

    // MARK: - Properties

    public let analytics: Analytics
    public let crashReporter: CrashReporter

    private var isInitialized = false

    // MARK: - Initialization

    public init(analytics: Analytics, crashReporter: CrashReporter) {
        self.analytics = analytics
        self.crashReporter = crashReporter
    }

    // MARK: - Public Methods

    /// Initialize all platform services
    /// This should be called once during SDK startup
    public func initialize() async {
        guard !isInitialized else { return }

        do {
            // Initialize crash reporter first to catch any initialization errors
            await crashReporter.initialize()
            await crashReporter.log("Platform initialization started", level: .info)

            // Analytics doesn't need explicit initialization as it's handled internally

            isInitialized = true

            // Log successful initialization
            await crashReporter.log("Platform initialization completed successfully", level: .info)
            await analytics.track(eventName: "platform_initialized", properties: [:])

        } catch {
            await crashReporter.recordException(error, tags: ["context": "platform_initialization"])
            print("[JarvisPlatform] Initialization failed: \(error.localizedDescription)")
        }
    }

    /// Check if platform is initialized
    public func getIsInitialized() -> Bool {
        return isInitialized
    }

    /// Enable or disable platform services
    public func setEnabled(_ enabled: Bool) async {
        guard isInitialized else {
            print("[JarvisPlatform] Platform must be initialized before enabling/disabling")
            return
        }

        await analytics.setEnabled(enabled)
        await crashReporter.setEnabled(enabled)

        await crashReporter.log("Platform services \(enabled ? "enabled" : "disabled")", level: .info)

        if enabled {
            await analytics.track(eventName: "platform_enabled", properties: [:])
        } else {
            await analytics.track(eventName: "platform_disabled", properties: [:])
        }
    }

    /// Track app lifecycle events
    public func onAppStart() async {
        guard isInitialized else { return }

        await analytics.track(eventName: "app_started", properties: [:])
        await crashReporter.addBreadcrumb(message: "App started", category: "lifecycle", level: .info)
    }

    public func onAppStop() async {
        guard isInitialized else { return }

        await analytics.track(eventName: "app_stopped", properties: [:])
        await crashReporter.addBreadcrumb(message: "App stopped", category: "lifecycle", level: .info)
        await analytics.flush()
    }

    /// Set user information across all platform services
    public func setUser(
        userId: String,
        email: String? = nil,
        username: String? = nil,
        properties: [String: Any] = [:]
    ) async {
        guard isInitialized else { return }

        // Set user in crash reporter
        await crashReporter.setUser(userId: userId, email: email, username: username)

        // Set user in analytics
        var userProperties = properties
        if let username = username {
            userProperties["name"] = username
        }

        let userProfile = UserProfile(
            userId: userId,
            properties: userProperties,
            email: email,
            name: username
        )
        await analytics.identify(userProfile: userProfile)
    }

    // MARK: - Version

    public static let version = "1.0.0"
}