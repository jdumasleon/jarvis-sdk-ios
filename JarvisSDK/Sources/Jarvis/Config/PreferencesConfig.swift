import Foundation
import JarvisPreferencesDomain

/// Configuration for preferences inspection features
public struct PreferencesConfig {
    /// Configuration for scanning host app preferences
    public let configuration: PreferencesConfiguration

    public init(
        configuration: PreferencesConfiguration = .default
    ) {
        self.configuration = configuration
    }

    /// Builder pattern for convenient configuration
    public final class Builder {
        private var configuration: PreferencesConfiguration = .default

        public init() {}

        public func configuration(_ config: PreferencesConfiguration) -> Builder {
            self.configuration = config
            return self
        }

        public func autoDiscoverUserDefaults(_ enabled: Bool) -> Builder {
            self.configuration = PreferencesConfiguration(
                autoDiscoverUserDefaults: enabled,
                includeUserDefaultsSuites: configuration.includeUserDefaultsSuites,
                excludeUserDefaultsSuites: configuration.excludeUserDefaultsSuites,
                autoDiscoverKeychain: configuration.autoDiscoverKeychain,
                includeKeychainServices: configuration.includeKeychainServices,
                excludeKeychainServices: configuration.excludeKeychainServices,
                enablePreferenceEditing: configuration.enablePreferenceEditing,
                showSystemPreferences: configuration.showSystemPreferences,
                enableRealtimeMonitoring: configuration.enableRealtimeMonitoring
            )
            return self
        }

        public func autoDiscoverKeychain(_ enabled: Bool) -> Builder {
            self.configuration = PreferencesConfiguration(
                autoDiscoverUserDefaults: configuration.autoDiscoverUserDefaults,
                includeUserDefaultsSuites: configuration.includeUserDefaultsSuites,
                excludeUserDefaultsSuites: configuration.excludeUserDefaultsSuites,
                autoDiscoverKeychain: enabled,
                includeKeychainServices: configuration.includeKeychainServices,
                excludeKeychainServices: configuration.excludeKeychainServices,
                enablePreferenceEditing: configuration.enablePreferenceEditing,
                showSystemPreferences: configuration.showSystemPreferences,
                enableRealtimeMonitoring: configuration.enableRealtimeMonitoring
            )
            return self
        }

        public func includeUserDefaultsSuites(_ suites: [String]) -> Builder {
            self.configuration = PreferencesConfiguration(
                autoDiscoverUserDefaults: configuration.autoDiscoverUserDefaults,
                includeUserDefaultsSuites: suites,
                excludeUserDefaultsSuites: configuration.excludeUserDefaultsSuites,
                autoDiscoverKeychain: configuration.autoDiscoverKeychain,
                includeKeychainServices: configuration.includeKeychainServices,
                excludeKeychainServices: configuration.excludeKeychainServices,
                enablePreferenceEditing: configuration.enablePreferenceEditing,
                showSystemPreferences: configuration.showSystemPreferences,
                enableRealtimeMonitoring: configuration.enableRealtimeMonitoring
            )
            return self
        }

        public func excludeUserDefaultsSuites(_ suites: [String]) -> Builder {
            self.configuration = PreferencesConfiguration(
                autoDiscoverUserDefaults: configuration.autoDiscoverUserDefaults,
                includeUserDefaultsSuites: configuration.includeUserDefaultsSuites,
                excludeUserDefaultsSuites: suites,
                autoDiscoverKeychain: configuration.autoDiscoverKeychain,
                includeKeychainServices: configuration.includeKeychainServices,
                excludeKeychainServices: configuration.excludeKeychainServices,
                enablePreferenceEditing: configuration.enablePreferenceEditing,
                showSystemPreferences: configuration.showSystemPreferences,
                enableRealtimeMonitoring: configuration.enableRealtimeMonitoring
            )
            return self
        }

        public func showSystemPreferences(_ enabled: Bool) -> Builder {
            self.configuration = PreferencesConfiguration(
                autoDiscoverUserDefaults: configuration.autoDiscoverUserDefaults,
                includeUserDefaultsSuites: configuration.includeUserDefaultsSuites,
                excludeUserDefaultsSuites: configuration.excludeUserDefaultsSuites,
                autoDiscoverKeychain: configuration.autoDiscoverKeychain,
                includeKeychainServices: configuration.includeKeychainServices,
                excludeKeychainServices: configuration.excludeKeychainServices,
                enablePreferenceEditing: configuration.enablePreferenceEditing,
                showSystemPreferences: enabled,
                enableRealtimeMonitoring: configuration.enableRealtimeMonitoring
            )
            return self
        }

        public func build() -> PreferencesConfig {
            return PreferencesConfig(configuration: configuration)
        }
    }

    public static func builder() -> Builder {
        return Builder()
    }
}
