import Foundation

/// Utility for truncating large request/response bodies to prevent memory issues
public struct BodyTruncation {

    /// Maximum body size in bytes (250KB like Android)
    public static let maxBodySize: Int = 250_000

    /// Truncates body data if it exceeds the maximum size
    /// - Parameter body: Original body data
    /// - Returns: Truncated body data with size info, or original if under limit
    public static func truncateIfNeeded(_ body: Data?) -> Data? {
        guard let body = body else { return nil }

        // If body is within limits, return as-is
        if body.count <= maxBodySize {
            return body
        }

        // Create truncation message
        let message = """
        [Content too large: \(formatBytes(body.count))]
        [Showing first \(formatBytes(maxBodySize)) of \(formatBytes(body.count))]
        [Content truncated to prevent memory issues]

        """

        guard let messageData = message.data(using: .utf8) else {
            return truncateData(body)
        }

        // Combine message + truncated data
        var result = Data()
        result.append(messageData)
        result.append(truncateData(body))

        return result
    }

    /// Truncates data to max size
    private static func truncateData(_ data: Data) -> Data {
        return data.prefix(maxBodySize)
    }

    /// Formats bytes into human-readable format
    /// - Parameter bytes: Number of bytes
    /// - Returns: Formatted string (e.g., "250 KB", "1.5 MB")
    private static func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    /// Checks if body should be truncated
    /// - Parameter body: Body data
    /// - Returns: true if body exceeds max size
    public static func shouldTruncate(_ body: Data?) -> Bool {
        guard let body = body else { return false }
        return body.count > maxBodySize
    }

    /// Gets truncation info for a body
    /// - Parameter body: Original body data
    /// - Returns: Truncation info or nil if not truncated
    public static func getTruncationInfo(_ body: Data?) -> TruncationInfo? {
        guard let body = body, shouldTruncate(body) else {
            return nil
        }

        return TruncationInfo(
            originalSize: body.count,
            truncatedSize: maxBodySize,
            originalSizeFormatted: formatBytes(body.count),
            truncatedSizeFormatted: formatBytes(maxBodySize)
        )
    }

    /// Information about body truncation
    public struct TruncationInfo {
        public let originalSize: Int
        public let truncatedSize: Int
        public let originalSizeFormatted: String
        public let truncatedSizeFormatted: String

        public var message: String {
            "Content truncated: \(originalSizeFormatted) → \(truncatedSizeFormatted)"
        }
    }
}
