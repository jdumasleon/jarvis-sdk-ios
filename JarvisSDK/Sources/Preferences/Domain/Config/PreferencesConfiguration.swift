//
//  PreferencesConfiguration.swift
//  JarvisSDK
//
//  Configuration for SDK preference scanning
//  Similar to Android's PreferencesConfiguration
//

import Foundation

/// Configuration for how the SDK scans and monitors host app preferences
/// iOS can automatically scan all preferences - no registration needed!
public struct PreferencesConfiguration {

    // MARK: - UserDefaults Configuration

    /// Automatically discover all UserDefaults suites by scanning Library/Preferences/*.plist
    /// Default: true - scans all .plist files automatically
    public let autoDiscoverUserDefaults: Bool

    /// Explicitly include only these UserDefaults suite names (optional filtering)
    /// If empty, all discovered suites are included
    public let includeUserDefaultsSuites: [String]

    /// Exclude these UserDefaults suite names from scanning (optional filtering)
    /// Useful for hiding sensitive data
    public let excludeUserDefaultsSuites: [String]

    // MARK: - Keychain Configuration

    /// Automatically discover Keychain services by querying SecItemCopyMatching
    /// Default: true - queries all Keychain items automatically
    public let autoDiscoverKeychain: Bool

    /// Explicitly include only these Keychain service identifiers (optional filtering)
    /// If empty, all discovered services are included
    public let includeKeychainServices: [String]

    /// Exclude these Keychain service identifiers (optional filtering)
    /// Useful for hiding sensitive services
    public let excludeKeychainServices: [String]

    // MARK: - Feature Flags

    /// Allow editing preferences through the SDK UI
    public let enablePreferenceEditing: Bool

    /// Show system preferences (Apple*, NS*, AK* keys in UserDefaults)
    /// Default: false - hides iOS system keys
    public let showSystemPreferences: Bool

    /// Enable real-time monitoring of preference changes
    public let enableRealtimeMonitoring: Bool

    // MARK: - Initialization

    public init(
        autoDiscoverUserDefaults: Bool = true,
        includeUserDefaultsSuites: [String] = [],
        excludeUserDefaultsSuites: [String] = [],
        autoDiscoverKeychain: Bool = true,
        includeKeychainServices: [String] = [],
        excludeKeychainServices: [String] = [],
        enablePreferenceEditing: Bool = true,
        showSystemPreferences: Bool = false,
        enableRealtimeMonitoring: Bool = true
    ) {
        self.autoDiscoverUserDefaults = autoDiscoverUserDefaults
        self.includeUserDefaultsSuites = includeUserDefaultsSuites
        self.excludeUserDefaultsSuites = excludeUserDefaultsSuites
        self.autoDiscoverKeychain = autoDiscoverKeychain
        self.includeKeychainServices = includeKeychainServices
        self.excludeKeychainServices = excludeKeychainServices
        self.enablePreferenceEditing = enablePreferenceEditing
        self.showSystemPreferences = showSystemPreferences
        self.enableRealtimeMonitoring = enableRealtimeMonitoring
    }

    /// Default configuration - auto-discovers everything with minimal configuration
    public static let `default` = PreferencesConfiguration()
}

/// Protocol for providing preferences configuration
public protocol PreferencesConfigProvider {
    func getConfiguration() -> PreferencesConfiguration
    func updateConfiguration(_ configuration: PreferencesConfiguration)
}

/// Default implementation of configuration provider
public class DefaultPreferencesConfigProvider: PreferencesConfigProvider {
    private var configuration: PreferencesConfiguration

    public init(configuration: PreferencesConfiguration = .default) {
        self.configuration = configuration
    }

    public func getConfiguration() -> PreferencesConfiguration {
        return configuration
    }

    public func updateConfiguration(_ configuration: PreferencesConfiguration) {
        self.configuration = configuration
    }
}
