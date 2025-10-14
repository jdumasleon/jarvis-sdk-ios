import Foundation

// MARK: - String Extensions
public extension String {
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Safe subscript for string indexing
    subscript(safe index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Truncate string to specified length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count <= length {
            return self
        }
        return String(prefix(length)) + trailing
    }
}

// MARK: - Data Extensions
public extension Data {
    /// Convert data to pretty printed JSON string
    var prettyPrintedJSON: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return prettyPrintedString
    }

    /// Convert data to hex string
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Date Extensions
public extension Date {
    /// Format date as ISO 8601 string
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }

    /// Format date for display
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = style
        return formatter.string(from: self)
    }

    /// Time ago string (e.g., "2 minutes ago")
    var timeAgoString: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)

        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Dictionary Extensions
public extension Dictionary where Key == String, Value == Any {
    /// Safe string value retrieval
    func stringValue(for key: String) -> String? {
        return self[key] as? String
    }

    /// Safe integer value retrieval
    func intValue(for key: String) -> Int? {
        if let value = self[key] as? Int {
            return value
        } else if let stringValue = self[key] as? String {
            return Int(stringValue)
        }
        return nil
    }

    /// Safe boolean value retrieval
    func boolValue(for key: String) -> Bool? {
        if let value = self[key] as? Bool {
            return value
        } else if let stringValue = self[key] as? String {
            return Bool(stringValue)
        }
        return nil
    }
}

// MARK: - Array Extensions
public extension Array {
    /// Safe element access
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }

    /// Remove duplicates while preserving order
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

// MARK: - URL Extensions
public extension URL {
    /// Extract query parameters as dictionary
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return [:]
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }

    /// Create URL with query parameters
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true) ?? URLComponents()

        var queryItems = components.queryItems ?? []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        components.queryItems = queryItems
        return components.url ?? self
    }
}