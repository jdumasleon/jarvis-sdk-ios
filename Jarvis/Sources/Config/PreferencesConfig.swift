import Foundation

/// Configuration for preferences inspection features
public struct PreferencesConfig {
    public let enableUserDefaultsMonitoring: Bool
    public let enableKeychainMonitoring: Bool
    public let enableFileBasedPreferencesMonitoring: Bool
    public let excludeKeys: [String]
    public let includeOnlyKeys: [String]
    public let monitoringInterval: TimeInterval

    public init(
        enableUserDefaultsMonitoring: Bool = true,
        enableKeychainMonitoring: Bool = false,
        enableFileBasedPreferencesMonitoring: Bool = false,
        excludeKeys: [String] = [],
        includeOnlyKeys: [String] = [],
        monitoringInterval: TimeInterval = 1.0
    ) {
        self.enableUserDefaultsMonitoring = enableUserDefaultsMonitoring
        self.enableKeychainMonitoring = enableKeychainMonitoring
        self.enableFileBasedPreferencesMonitoring = enableFileBasedPreferencesMonitoring
        self.excludeKeys = excludeKeys
        self.includeOnlyKeys = includeOnlyKeys
        self.monitoringInterval = monitoringInterval
    }

    /// Builder pattern for convenient configuration
    public final class Builder {
        private var enableUserDefaultsMonitoring: Bool = true
        private var enableKeychainMonitoring: Bool = false
        private var enableFileBasedPreferencesMonitoring: Bool = false
        private var excludeKeys: [String] = []
        private var includeOnlyKeys: [String] = []
        private var monitoringInterval: TimeInterval = 1.0

        public init() {}

        public func enableUserDefaultsMonitoring(_ enabled: Bool) -> Builder {
            self.enableUserDefaultsMonitoring = enabled
            return self
        }

        public func enableKeychainMonitoring(_ enabled: Bool) -> Builder {
            self.enableKeychainMonitoring = enabled
            return self
        }

        public func enableFileBasedPreferencesMonitoring(_ enabled: Bool) -> Builder {
            self.enableFileBasedPreferencesMonitoring = enabled
            return self
        }

        public func excludeKeys(_ keys: [String]) -> Builder {
            self.excludeKeys = keys
            return self
        }

        public func excludeKeys(_ keys: String...) -> Builder {
            self.excludeKeys = keys
            return self
        }

        public func includeOnlyKeys(_ keys: [String]) -> Builder {
            self.includeOnlyKeys = keys
            return self
        }

        public func includeOnlyKeys(_ keys: String...) -> Builder {
            self.includeOnlyKeys = keys
            return self
        }

        public func monitoringInterval(_ interval: TimeInterval) -> Builder {
            self.monitoringInterval = interval
            return self
        }

        public func build() -> PreferencesConfig {
            return PreferencesConfig(
                enableUserDefaultsMonitoring: enableUserDefaultsMonitoring,
                enableKeychainMonitoring: enableKeychainMonitoring,
                enableFileBasedPreferencesMonitoring: enableFileBasedPreferencesMonitoring,
                excludeKeys: excludeKeys,
                includeOnlyKeys: includeOnlyKeys,
                monitoringInterval: monitoringInterval
            )
        }
    }

    public static func builder() -> Builder {
        return Builder()
    }
}