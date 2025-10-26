//
//  DemoPreferencesRepository.swift
//  JarvisDemo
//
//  Unified repository combining all demo app preference sources
//

import Foundation
import Combine

/// Repository for managing demo app's own preferences
class DemoPreferencesRepository {

    // MARK: - Properties

    private let userDefaultsManager: DemoUserDefaultsManager
    private let keychainManager: DemoKeychainManager

    // MARK: - Initialization

    init(
        userDefaultsManager: DemoUserDefaultsManager = DemoUserDefaultsManager(),
        keychainManager: DemoKeychainManager = DemoKeychainManager()
    ) {
        self.userDefaultsManager = userDefaultsManager
        self.keychainManager = keychainManager
    }

    // MARK: - Public API

    /// Get all preferences from all sources as a combined Flow/Publisher
    func getAllPreferencesPublisher() -> AnyPublisher<[DemoPreferenceItem], Never> {
        // Combine UserDefaults and Keychain preferences
        return userDefaultsManager.getAllPreferencesPublisher()
            .map { [weak self] userDefaultsPrefs in
                guard let self = self else { return [] }

                var allPreferences: [DemoPreferenceItem] = []

                // Add UserDefaults preferences
                allPreferences.append(contentsOf: userDefaultsPrefs)

                // Add Keychain preferences
                allPreferences.append(contentsOf: self.keychainManager.getAllPreferences())

                return allPreferences.sorted { $0.key < $1.key }
            }
            .eraseToAnyPublisher()
    }

    /// Get all preferences synchronously
    func getAllPreferences() -> [DemoPreferenceItem] {
        var allPreferences: [DemoPreferenceItem] = []

        // Get UserDefaults preferences
        allPreferences.append(contentsOf: userDefaultsManager.getAllPreferences())

        // Get Keychain preferences
        allPreferences.append(contentsOf: keychainManager.getAllPreferences())

        return allPreferences.sorted { $0.key < $1.key }
    }

    /// Get preferences filtered by storage type
    func getPreferences(by storageType: DemoPreferenceStorageType) -> [DemoPreferenceItem] {
        return getAllPreferences().filter { $0.storageType == storageType }
    }

    /// Set a preference value
    func setPreference(key: String, value: String, type: DemoPreferenceType, storageType: DemoPreferenceStorageType, suite: String) {
        switch storageType {
        case .userDefaults:
            let convertedValue = convertValue(value, to: type)
            // Determine which suite to use based on suite name
            if suite == DemoUserDefaultsManager.demoPrefsName {
                userDefaultsManager.setDemoPreference(key: key, value: convertedValue)
            } else if suite == DemoUserDefaultsManager.userPrefsName {
                userDefaultsManager.setUserPreference(key: key, value: convertedValue)
            } else if suite == DemoUserDefaultsManager.appSettingsName {
                userDefaultsManager.setAppSetting(key: key, value: convertedValue)
            } else if suite == DemoUserDefaultsManager.cacheSettingsName {
                userDefaultsManager.setCacheSetting(key: key, value: convertedValue)
            }

        case .keychain:
            keychainManager.setValue(value, forKey: key)

        case .propertyList:
            // TODO: Implement if needed
            break
        }
    }

    /// Delete a preference
    func deletePreference(key: String, storageType: DemoPreferenceStorageType) {
        switch storageType {
        case .userDefaults:
            // Remove from all suites
            userDefaultsManager.getDemoPrefs().removeObject(forKey: key)
            userDefaultsManager.getUserPrefs().removeObject(forKey: key)
            userDefaultsManager.getAppSettings().removeObject(forKey: key)
            userDefaultsManager.getCacheSettings().removeObject(forKey: key)

        case .keychain:
            keychainManager.removeValue(forKey: key)

        case .propertyList:
            // TODO: Implement if needed
            break
        }
    }

    /// Generate sample data for all storage types
    func generateSampleData() {
        userDefaultsManager.generateSampleUserDefaults()
        keychainManager.generateSampleKeychain()
    }

    // MARK: - Helper Methods

    private func convertValue(_ value: String, to type: DemoPreferenceType) -> Any {
        switch type {
        case .string:
            return value
        case .integer:
            return Int(value) ?? 0
        case .boolean:
            return Bool(value) ?? false
        case .float:
            return Double(value) ?? 0.0
        case .data:
            return value.data(using: .utf8) ?? Data()
        case .array:
            // Try to parse as JSON array
            if let data = value.data(using: .utf8),
               let array = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                return array
            }
            return [value]
        case .dictionary:
            // Try to parse as JSON dictionary
            if let data = value.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return dict
            }
            return ["value": value]
        }
    }

    // MARK: - Access for SDK Registration

    func getUserDefaultsManager() -> DemoUserDefaultsManager {
        return userDefaultsManager
    }

    func getKeychainManager() -> DemoKeychainManager {
        return keychainManager
    }
}
