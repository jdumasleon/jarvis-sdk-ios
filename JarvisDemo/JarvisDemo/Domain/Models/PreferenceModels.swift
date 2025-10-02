//
//  PreferenceModels.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon on 2/10/25.
//

import Foundation

enum PreferenceStorageType: CaseIterable {
    case userDefaults
    case keychain
    case coreData

    var displayName: String {
        switch self {
        case .userDefaults: return "UserDefaults"
        case .keychain: return "Keychain"
        case .coreData: return "Core Data"
        }
    }
}

enum PreferenceType: CaseIterable {
    case string
    case boolean
    case number
    case data

    var displayName: String {
        switch self {
        case .string: return "String"
        case .boolean: return "Boolean"
        case .number: return "Number"
        case .data: return "Data"
        }
    }
}

struct PreferenceItem: Identifiable {
    let id = UUID()
    let key: String
    let value: String
    let type: PreferenceType
    let storageType: PreferenceStorageType

    static let mockPreferences: [PreferenceItem] = [
        // UserDefaults
        PreferenceItem(key: "user_name", value: "John Doe", type: .string, storageType: .userDefaults),
        PreferenceItem(key: "is_first_launch", value: "false", type: .boolean, storageType: .userDefaults),
        PreferenceItem(key: "app_launch_count", value: "42", type: .number, storageType: .userDefaults),
        PreferenceItem(key: "theme_preference", value: "dark", type: .string, storageType: .userDefaults),
        PreferenceItem(key: "notifications_enabled", value: "true", type: .boolean, storageType: .userDefaults),

        // Keychain
        PreferenceItem(key: "auth_token", value: "eyJhbGciOiJIUzI1NiIs...", type: .string, storageType: .keychain),
        PreferenceItem(key: "biometric_enabled", value: "true", type: .boolean, storageType: .keychain),
        PreferenceItem(key: "refresh_token", value: "dGVzdF9yZWZyZXNo...", type: .string, storageType: .keychain),

        // Core Data
        PreferenceItem(key: "cached_user_count", value: "1250", type: .number, storageType: .coreData),
        PreferenceItem(key: "sync_enabled", value: "true", type: .boolean, storageType: .coreData),
        PreferenceItem(key: "last_sync_date", value: "2025-01-01T10:30:00Z", type: .string, storageType: .coreData),
    ]
}
