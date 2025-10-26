//
//  DemoKeychainManager.swift
//  JarvisDemo
//
//  Demo app's own Keychain manager
//

import Foundation
import Security
import Combine

/// Demo app's own Keychain manager for secure storage
class DemoKeychainManager {

    // MARK: - Properties

    private let service: String

    // MARK: - Initialization

    init(service: String = "com.jarvis.demo.keychain") {
        self.service = service
    }

    // MARK: - Public API

    /// Get all keychain items
    func getAllPreferences() -> [DemoPreferenceItem] {
        var items: [DemoPreferenceItem] = []

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keychainItems = result as? [[String: Any]] else {
            return []
        }

        for item in keychainItems {
            guard let account = item[kSecAttrAccount as String] as? String,
                  let data = item[kSecValueData as String] as? Data else {
                continue
            }

            let value = String(data: data, encoding: .utf8) ?? data.base64EncodedString()

            items.append(DemoPreferenceItem(
                key: account,
                value: value,
                type: .string,
                storageType: .keychain,
                suite: service
            ))
        }

        return items.sorted { $0.key < $1.key }
    }

    /// Get value for a specific key
    func getValue(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Set value for a specific key
    @discardableResult
    func setValue(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Remove value for a specific key
    @discardableResult
    func removeValue(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Generate Sample Data

    func generateSampleKeychain() {
        setValue("demo_auth_token_abc123xyz", forKey: "auth_token")
        setValue("demo_api_key_xyz789abc", forKey: "api_key")
        setValue("john.doe@example.com", forKey: "user_email_encrypted")
        setValue("true", forKey: "biometric_enabled")
        setValue("demo_refresh_token_qwe456rty", forKey: "refresh_token")
        setValue("SecurePassword123!", forKey: "cached_password")
    }

    // MARK: - Access for SDK Registration

    func getService() -> String {
        return service
    }
}
