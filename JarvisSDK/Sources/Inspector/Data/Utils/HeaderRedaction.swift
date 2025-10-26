import Foundation

/// Utility for redacting sensitive headers from network requests/responses
public struct HeaderRedaction {

    /// List of sensitive header names that should be redacted
    private static let sensitiveHeaders: Set<String> = [
        "authorization",
        "cookie",
        "set-cookie",
        "x-api-key",
        "x-auth-token",
        "authentication",
        "proxy-authorization",
        "www-authenticate",
        "x-csrf-token",
        "x-xsrf-token",
        "api-key",
        "apikey",
        "access-token",
        "bearer",
        "session",
        "sessionid",
        "x-session-id",
        "x-access-token",
        "x-refresh-token"
    ]

    /// Redaction marker
    private static let redactionMarker = "██████"

    /// Redacts sensitive headers from a dictionary
    /// - Parameter headers: Original headers dictionary
    /// - Returns: New dictionary with sensitive values redacted
    public static func redactHeaders(_ headers: [String: String]) -> [String: String] {
        var redacted = headers

        for (key, _) in headers {
            if shouldRedact(headerName: key) {
                redacted[key] = redactionMarker
            }
        }

        return redacted
    }

    /// Checks if a header name should be redacted
    /// - Parameter headerName: The header name to check
    /// - Returns: true if the header should be redacted
    private static func shouldRedact(headerName: String) -> Bool {
        let lowercased = headerName.lowercased()

        // Check exact match
        if sensitiveHeaders.contains(lowercased) {
            return true
        }

        // Check if contains sensitive keywords
        for sensitiveHeader in sensitiveHeaders {
            if lowercased.contains(sensitiveHeader) {
                return true
            }
        }

        return false
    }

    /// Redacts sensitive data from request/response body if it contains JSON with sensitive keys
    /// - Parameter body: Original body data
    /// - Returns: Redacted body data if JSON, otherwise original
    public static func redactBodyIfNeeded(_ body: Data?) -> Data? {
        guard let body = body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] else {
            return body
        }

        let redactedJSON = redactJSONValues(json)

        return try? JSONSerialization.data(withJSONObject: redactedJSON)
    }

    /// Recursively redacts sensitive values in JSON
    private static func redactJSONValues(_ json: [String: Any]) -> [String: Any] {
        var redacted = json

        for (key, value) in json {
            let lowercasedKey = key.lowercased()

            // Redact if key contains sensitive keywords
            if sensitiveHeaders.contains(lowercasedKey) ||
               lowercasedKey.contains("password") ||
               lowercasedKey.contains("secret") ||
               lowercasedKey.contains("token") ||
               lowercasedKey.contains("key") {
                redacted[key] = redactionMarker
            } else if let nestedDict = value as? [String: Any] {
                // Recursively redact nested objects
                redacted[key] = redactJSONValues(nestedDict)
            } else if let nestedArray = value as? [[String: Any]] {
                // Recursively redact arrays of objects
                redacted[key] = nestedArray.map { redactJSONValues($0) }
            }
        }

        return redacted
    }
}
