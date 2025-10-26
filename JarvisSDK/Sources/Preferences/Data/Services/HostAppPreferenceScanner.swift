//
//  PreferenceScanner.swift
//  JarvisSDK
//
//  Main service for scanning host app preferences
//  Coordinates UserDefaults and Keychain scanners
//

import Foundation
import Combine
import JarvisPreferencesDomain

/// Main scanner service for discovering all host app preferences
public class PreferenceScanner {

    // MARK: - Properties

    private let configProvider: PreferencesConfigProvider
    private let userDefaultsScanner: UserDefaultsScanner
    private let keychainScanner: KeychainScanner

    // MARK: - Initialization

    public init(configProvider: PreferencesConfigProvider) {
        self.configProvider = configProvider
        self.userDefaultsScanner = UserDefaultsScanner(configProvider: configProvider)
        self.keychainScanner = KeychainScanner(configProvider: configProvider)
    }

    // MARK: - Public API

    /// Scan all host app preferences from all sources
    public func scanAllPreferences() -> [Preference] {
        var allPreferences: [Preference] = []

        // Scan UserDefaults
        allPreferences.append(contentsOf: userDefaultsScanner.scanAllUserDefaults())

        // Scan Keychain
        allPreferences.append(contentsOf: keychainScanner.scanAllKeychain())

        return allPreferences.sorted { $0.key < $1.key }
    }

    /// Scan preferences by source type
    public func scanPreferences(by source: PreferenceSource) -> [Preference] {
        switch source {
        case .userDefaults:
            return userDefaultsScanner.scanAllUserDefaults()
        case .keychain:
            return keychainScanner.scanAllKeychain()
        case .propertyList:
            return [] // Not implemented yet
        }
    }

    /// Get scanner for specific source
    public func getUserDefaultsScanner() -> UserDefaultsScanner {
        return userDefaultsScanner
    }

    public func getKeychainScanner() -> KeychainScanner {
        return keychainScanner
    }
}
