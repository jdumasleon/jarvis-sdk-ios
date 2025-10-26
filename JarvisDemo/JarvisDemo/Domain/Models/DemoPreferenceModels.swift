//
//  DemoPreferenceModels.swift
//  JarvisDemo
//
//  Demo app's own preference models
//

import Foundation

/// Demo app's preference item model
struct DemoPreferenceItem: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let value: String
    let type: DemoPreferenceType
    let storageType: DemoPreferenceStorageType
    let suite: String  // UserDefaults suite name or Keychain service name

    static func == (lhs: DemoPreferenceItem, rhs: DemoPreferenceItem) -> Bool {
        return lhs.key == rhs.key &&
               lhs.value == rhs.value &&
               lhs.type == rhs.type &&
               lhs.storageType == rhs.storageType &&
               lhs.suite == rhs.suite
    }
}

/// Type of preference value
enum DemoPreferenceType: String, CaseIterable {
    case string = "String"
    case integer = "Integer"
    case boolean = "Boolean"
    case float = "Float"
    case data = "Data"
    case array = "Array"
    case dictionary = "Dictionary"

    var displayName: String {
        return rawValue
    }
}

/// Where the preference is stored
enum DemoPreferenceStorageType: String, CaseIterable {
    case userDefaults = "UserDefaults"
    case keychain = "Keychain"
    case propertyList = "Property List"

    var displayName: String {
        return rawValue
    }
}
