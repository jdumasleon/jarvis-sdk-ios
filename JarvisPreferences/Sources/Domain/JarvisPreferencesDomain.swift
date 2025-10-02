import Foundation
import JarvisCommon
import JarvisDomain

/// Preferences monitoring domain layer
/// Contains business logic for monitoring app preferences and settings changes
public struct JarvisPreferencesDomain {
    public static let version = "1.0.0"
}

// MARK: - Preferences Entities

/// Preference change entity
public struct PreferenceChange {
    public let id: String
    public let key: String
    public let oldValue: Any?
    public let newValue: Any?
    public let timestamp: Date
    public let source: PreferenceSource

    public init(
        id: String = UUID().uuidString,
        key: String,
        oldValue: Any? = nil,
        newValue: Any?,
        timestamp: Date = Date(),
        source: PreferenceSource
    ) {
        self.id = id
        self.key = key
        self.oldValue = oldValue
        self.newValue = newValue
        self.timestamp = timestamp
        self.source = source
    }
}

/// Source of preference change
public enum PreferenceSource: String, CaseIterable {
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case coreData = "CoreData"
    case cloudKit = "CloudKit"
    case custom = "Custom"
}

// MARK: - Use Cases

/// Monitor preferences changes use case
public struct MonitorPreferencesUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = [PreferenceChange]

    public init() {}

    public func execute(_ input: Void) async throws -> [PreferenceChange] {
        // Implementation will be added later
        return []
    }
}

/// Get preferences history use case
public struct GetPreferencesHistoryUseCase: UseCase {
    public typealias Input = String // Preference key
    public typealias Output = [PreferenceChange]

    public init() {}

    public func execute(_ input: String) async throws -> [PreferenceChange] {
        // Implementation will be added later
        return []
    }
}