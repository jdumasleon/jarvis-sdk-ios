//
//  Preference.swift
//  JarvisSDK
//
//  Represents a preference item from the host app
//

import Foundation

/// Represents a scanned preference from the host app
public struct Preference: Identifiable, Equatable {
    public let id: String
    public let key: String
    public let value: Any
    public let type: String
    public let source: PreferenceSource
    public let suiteName: String?
    public let timestamp: Date

    public init(
        id: String,
        key: String,
        value: Any,
        type: String,
        source: PreferenceSource,
        suiteName: String? = nil,
        timestamp: Date
    ) {
        self.id = id
        self.key = key
        self.value = value
        self.type = type
        self.source = source
        self.suiteName = suiteName
        self.timestamp = timestamp
    }

    public static func == (lhs: Preference, rhs: Preference) -> Bool {
        return lhs.id == rhs.id &&
               lhs.key == rhs.key &&
               String(describing: lhs.value) == String(describing: rhs.value) &&
               lhs.type == rhs.type &&
               lhs.source == rhs.source &&
               lhs.suiteName == rhs.suiteName
    }
}

/// Source of a preference
public enum PreferenceSource: String, Codable, CaseIterable {
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case propertyList = "PropertyList"
}
