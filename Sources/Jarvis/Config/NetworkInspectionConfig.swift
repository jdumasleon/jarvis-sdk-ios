import Foundation

/// Configuration for network inspection features
public struct NetworkInspectionConfig {
    public let enableNetworkLogging: Bool
    public let maxRequestBodySize: Int
    public let maxResponseBodySize: Int
    public let enableRequestLogging: Bool
    public let enableResponseLogging: Bool
    public let excludeHosts: [String]
    public let includeOnlyHosts: [String]

    public init(
        enableNetworkLogging: Bool = true,
        maxRequestBodySize: Int = 1024 * 1024, // 1MB
        maxResponseBodySize: Int = 1024 * 1024, // 1MB
        enableRequestLogging: Bool = true,
        enableResponseLogging: Bool = true,
        excludeHosts: [String] = [],
        includeOnlyHosts: [String] = []
    ) {
        self.enableNetworkLogging = enableNetworkLogging
        self.maxRequestBodySize = maxRequestBodySize
        self.maxResponseBodySize = maxResponseBodySize
        self.enableRequestLogging = enableRequestLogging
        self.enableResponseLogging = enableResponseLogging
        self.excludeHosts = excludeHosts
        self.includeOnlyHosts = includeOnlyHosts
    }

    /// Builder pattern for convenient configuration
    public final class Builder {
        private var enableNetworkLogging: Bool = true
        private var maxRequestBodySize: Int = 1024 * 1024
        private var maxResponseBodySize: Int = 1024 * 1024
        private var enableRequestLogging: Bool = true
        private var enableResponseLogging: Bool = true
        private var excludeHosts: [String] = []
        private var includeOnlyHosts: [String] = []

        public init() {}

        public func enableNetworkLogging(_ enabled: Bool) -> Builder {
            self.enableNetworkLogging = enabled
            return self
        }

        public func maxRequestBodySize(_ sizeInBytes: Int) -> Builder {
            self.maxRequestBodySize = sizeInBytes
            return self
        }

        public func maxResponseBodySize(_ sizeInBytes: Int) -> Builder {
            self.maxResponseBodySize = sizeInBytes
            return self
        }

        public func enableRequestLogging(_ enabled: Bool) -> Builder {
            self.enableRequestLogging = enabled
            return self
        }

        public func enableResponseLogging(_ enabled: Bool) -> Builder {
            self.enableResponseLogging = enabled
            return self
        }

        public func excludeHosts(_ hosts: [String]) -> Builder {
            self.excludeHosts = hosts
            return self
        }

        public func excludeHosts(_ hosts: String...) -> Builder {
            self.excludeHosts = hosts
            return self
        }

        public func includeOnlyHosts(_ hosts: [String]) -> Builder {
            self.includeOnlyHosts = hosts
            return self
        }

        public func includeOnlyHosts(_ hosts: String...) -> Builder {
            self.includeOnlyHosts = hosts
            return self
        }

        public func build() -> NetworkInspectionConfig {
            return NetworkInspectionConfig(
                enableNetworkLogging: enableNetworkLogging,
                maxRequestBodySize: maxRequestBodySize,
                maxResponseBodySize: maxResponseBodySize,
                enableRequestLogging: enableRequestLogging,
                enableResponseLogging: enableResponseLogging,
                excludeHosts: excludeHosts,
                includeOnlyHosts: includeOnlyHosts
            )
        }
    }

    public static func builder() -> Builder {
        return Builder()
    }
}