//
//  KeychainScanner.swift
//  JarvisSDK
//
//  Scans host app's Keychain with service-based discovery
//  Similar to Android's Keychain scanning
//

import Foundation
import Security
import JarvisPreferencesDomain

/// Scanner for discovering and reading Keychain items from the host app
public class KeychainScanner {

    // MARK: - Properties

    private let configProvider: PreferencesConfigProvider

    // MARK: - Initialization

    public init(configProvider: PreferencesConfigProvider) {
        self.configProvider = configProvider
    }

    // MARK: - Public API

    /// Scan all Keychain items based on configuration
    /// Auto-discovers all Keychain services by querying SecItemCopyMatching
    public func scanAllKeychain() -> [Preference] {
        let config = configProvider.getConfiguration()
        var preferences: [Preference] = []
        var scannedServices = Set<String>()

        // Step 1: Auto-discovery (if enabled) - query all Keychain items
        if config.autoDiscoverKeychain {
            let discoveredServices = discoverKeychainServices()

            for service in discoveredServices {
                // Apply include/exclude filters
                if shouldScanService(service, config: config) {
                    preferences.append(contentsOf: scanKeychainService(service: service))
                    scannedServices.insert(service)
                }
            }
        }

        // Step 2: Explicitly included services (if not already scanned)
        for service in config.includeKeychainServices {
            if !scannedServices.contains(service) {
                preferences.append(contentsOf: scanKeychainService(service: service))
            }
        }

        return preferences
    }

    // MARK: - Helper Methods

    /// Check if a service should be scanned based on include/exclude filters
    private func shouldScanService(_ service: String, config: PreferencesConfiguration) -> Bool {
        // If explicitly excluded, skip
        if config.excludeKeychainServices.contains(service) {
            return false
        }

        // If include list is specified, only scan those
        if !config.includeKeychainServices.isEmpty {
            return config.includeKeychainServices.contains(service)
        }

        // Otherwise, scan it
        return true
    }

    /// Discover Keychain services by querying all keychain items
    private func discoverKeychainServices() -> Set<String> {
        var discoveredServices = Set<String>()

        // Query for all generic password items (most common type)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return discoveredServices
        }

        // Extract unique service identifiers
        for item in items {
            if let service = item[kSecAttrService as String] as? String {
                discoveredServices.insert(service)
            }
        }

        return discoveredServices
    }

    /// Scan a specific Keychain service
    private func scanKeychainService(service: String) -> [Preference] {
        var preferences: [Preference] = []

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
              let items = result as? [[String: Any]] else {
            return []
        }

        for item in items {
            guard let account = item[kSecAttrAccount as String] as? String else {
                continue
            }

            // Extract value
            var value: String = "[Secure Data]"
            if let data = item[kSecValueData as String] as? Data {
                value = String(data: data, encoding: .utf8) ?? data.base64EncodedString()
            }

            let preference = Preference(
                id: UUID().uuidString,
                key: account,
                value: value,
                type: "String",
                source: .keychain,
                suiteName: service,
                timestamp: Date()
            )

            preferences.append(preference)
        }

        return preferences
    }
}
