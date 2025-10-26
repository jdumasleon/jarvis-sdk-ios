//
//  HostAppPreferenceRepository.swift
//  JarvisSDK
//
//  Repository implementation for host app preferences
//

import Foundation
import JarvisPreferencesDomain

/// Repository for managing host app preferences using scanners
public class PreferenceRepository: PreferenceRepositoryProtocol {

    private let scanner: PreferenceScanner
    private let configProvider: PreferencesConfigProvider

    public init(
        scanner: PreferenceScanner? = nil,
        configProvider: PreferencesConfigProvider? = nil
    ) {
        let provider = configProvider ?? DefaultPreferencesConfigProvider()
        self.configProvider = provider
        self.scanner = scanner ?? PreferenceScanner(configProvider: provider)
    }

    public func scanAllPreferences() -> [Preference] {
        return scanner.scanAllPreferences()
    }

    public func getPreferences(by source: PreferenceSource) -> [Preference] {
        return scanAllPreferences().filter { $0.source == source }
    }

    public func getPreferences(from suiteName: String) -> [Preference] {
        return scanAllPreferences().filter { $0.suiteName == suiteName }
    }

    public func updatePreference(
        key: String,
        value: Any,
        source: PreferenceSource,
        suiteName: String?
    ) -> Bool {
        switch source {
        case .userDefaults:
            guard let suite = suiteName,
                  let userDefaults = UserDefaults(suiteName: suite) else {
                return false
            }
            userDefaults.set(value, forKey: key)
            return true

        case .keychain:
            guard let service = suiteName,
                  let stringValue = value as? String,
                  let data = stringValue.data(using: .utf8) else {
                return false
            }

            // Delete existing
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            SecItemDelete(deleteQuery as CFDictionary)

            // Add new
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            return status == errSecSuccess

        case .propertyList:
            // TODO: Implement if needed
            return false
        }
    }

    public func deletePreference(
        key: String,
        source: PreferenceSource,
        suiteName: String?
    ) -> Bool {
        switch source {
        case .userDefaults:
            guard let suite = suiteName,
                  let userDefaults = UserDefaults(suiteName: suite) else {
                return false
            }
            userDefaults.removeObject(forKey: key)
            return true

        case .keychain:
            guard let service = suiteName else {
                return false
            }

            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            let status = SecItemDelete(query as CFDictionary)
            return status == errSecSuccess || status == errSecItemNotFound

        case .propertyList:
            // TODO: Implement if needed
            return false
        }
    }

    public func refresh() -> [Preference] {
        return scanAllPreferences()
    }
}
