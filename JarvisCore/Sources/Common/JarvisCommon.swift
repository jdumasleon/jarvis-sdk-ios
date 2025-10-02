import Foundation

/// Common utilities and extensions shared across the Jarvis SDK
public struct JarvisCommon {
    public static let version = "1.0.0"
}

// MARK: - Common Extensions

public extension String {
    /// Generate a UUID string
    static func uuid() -> String {
        UUID().uuidString
    }
}

public extension Date {
    /// Format date for Jarvis logging
    var jarvisTimestamp: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

// MARK: - Common Types

/// Result type for Jarvis operations
public typealias JarvisResult<T> = Result<T, JarvisError>

/// Common error types for Jarvis SDK
public enum JarvisError: Error, LocalizedError {
    case configurationError(String)
    case networkError(String)
    case parseError(String)
    case unknownError(String)

    public var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "Configuration Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .parseError(let message):
            return "Parse Error: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
}