import Foundation

public struct PreferenceItem: Identifiable, Hashable {
    public let id = UUID()
    public let key: String
    public let value: Any
    public let type: PreferenceType
    public let source: PreferenceSource
    
    public init(key: String, value: Any, type: PreferenceType, source: PreferenceSource) {
        self.key = key
        self.value = value
        self.type = type
        self.source = source
    }
    
    public static func == (lhs: PreferenceItem, rhs: PreferenceItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum PreferenceType: String, CaseIterable {
    case string = "String"
    case integer = "Integer"
    case double = "Double"
    case boolean = "Boolean"
    case data = "Data"
    case array = "Array"
    case dictionary = "Dictionary"
    case unknown = "Unknown"
    
    public static func from(_ value: Any) -> PreferenceType {
        switch value {
        case is String: return .string
        case is Int: return .integer
        case is Double: return .double
        case is Bool: return .boolean
        case is Data: return .data
        case is Array<Any>: return .array
        case is Dictionary<String, Any>: return .dictionary
        default: return .unknown
        }
    }
}

public enum PreferenceSource: String, CaseIterable {
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case plist = "Plist"
    case coreData = "Core Data"
    case custom = "Custom"
}