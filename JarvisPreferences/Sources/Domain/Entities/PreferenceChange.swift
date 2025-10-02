import Foundation

/// Preference change entity
public struct PreferenceChange: Identifiable {
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