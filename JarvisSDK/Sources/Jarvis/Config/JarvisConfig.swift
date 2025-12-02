import Foundation

/// Main configuration class for Jarvis SDK initialization
public struct JarvisConfig {
    public let preferences: PreferencesConfig
    public let networkInspection: NetworkInspectionConfig
    public let enableDebugLogging: Bool
    public let enableShakeDetection: Bool
    public let enableInternalTracking: Bool

    public init(
        preferences: PreferencesConfig = PreferencesConfig(),
        networkInspection: NetworkInspectionConfig = NetworkInspectionConfig(),
        enableDebugLogging: Bool = false,
        enableShakeDetection: Bool = true,
        enableInternalTracking: Bool = true
    ) {
        self.preferences = preferences
        self.networkInspection = networkInspection
        self.enableDebugLogging = enableDebugLogging
        self.enableShakeDetection = enableShakeDetection
        self.enableInternalTracking = enableInternalTracking
    }

    /// Builder pattern for convenient configuration
    public final class Builder {
        private var preferences: PreferencesConfig = PreferencesConfig()
        private var networkInspection: NetworkInspectionConfig = NetworkInspectionConfig()
        private var enableDebugLogging: Bool = false
        private var enableShakeDetection: Bool = true
        private var enableInternalTracking: Bool = true

        public init() {}

        public func preferences(_ config: PreferencesConfig) -> Builder {
            self.preferences = config
            return self
        }

        public func preferences(_ configure: (PreferencesConfig.Builder) -> Void) -> Builder {
            let builder = PreferencesConfig.Builder()
            configure(builder)
            self.preferences = builder.build()
            return self
        }

        public func networkInspection(_ config: NetworkInspectionConfig) -> Builder {
            self.networkInspection = config
            return self
        }

        public func networkInspection(_ configure: (NetworkInspectionConfig.Builder) -> Void) -> Builder {
            let builder = NetworkInspectionConfig.Builder()
            configure(builder)
            self.networkInspection = builder.build()
            return self
        }

        public func enableDebugLogging(_ enabled: Bool) -> Builder {
            self.enableDebugLogging = enabled
            return self
        }

        public func enableShakeDetection(_ enabled: Bool) -> Builder {
            self.enableShakeDetection = enabled
            return self
        }

        public func enableInternalTracking(_ enabled: Bool) -> Builder {
            self.enableInternalTracking = enabled
            return self
        }

        public func build() -> JarvisConfig {
            return JarvisConfig(
                preferences: preferences,
                networkInspection: networkInspection,
                enableDebugLogging: enableDebugLogging,
                enableShakeDetection: enableShakeDetection,
                enableInternalTracking: enableInternalTracking
            )
        }
    }

    public static func builder() -> Builder {
        return Builder()
    }
}
