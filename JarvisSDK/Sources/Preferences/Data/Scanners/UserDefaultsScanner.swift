//
//  UserDefaultsScanner.swift
//  JarvisSDK
//
//  Scans host app's UserDefaults with auto-discovery support
//  Similar to Android's SharedPreferencesScanner
//

import Foundation
import JarvisPreferencesDomain

/// Scanner for discovering and reading UserDefaults from the host app
public class UserDefaultsScanner {

    // MARK: - Properties

    private let configProvider: PreferencesConfigProvider

    // MARK: - Initialization

    public init(configProvider: PreferencesConfigProvider) {
        self.configProvider = configProvider
    }

    // MARK: - Public API

    /// Scan all UserDefaults based on configuration
    /// Auto-discovers all .plist files in Library/Preferences/
    public func scanAllUserDefaults() -> [Preference] {
        let config = configProvider.getConfiguration()
        var preferences: [Preference] = []
        var scannedSuites = Set<String>()

        // Step 1: Auto-discovery (if enabled) - scan all .plist files
        if config.autoDiscoverUserDefaults {
            let discoveredSuites = discoverUserDefaultsSuites()

            for suiteName in discoveredSuites {
                // Apply include/exclude filters
                if shouldScanSuite(suiteName, config: config) {
                    // Handle standard UserDefaults separately
                    if suiteName == "standard" {
                        preferences.append(contentsOf: extractPreferences(
                            from: UserDefaults.standard,
                            suiteName: "standard",
                            config: config
                        ))
                        scannedSuites.insert(suiteName)
                    } else if let userDefaults = UserDefaults(suiteName: suiteName) {
                        preferences.append(contentsOf: extractPreferences(
                            from: userDefaults,
                            suiteName: suiteName,
                            config: config
                        ))
                        scannedSuites.insert(suiteName)
                    }
                }
            }
        }

        // Step 2: Explicitly included suites (if not already scanned)
        for suiteName in config.includeUserDefaultsSuites {
            if !scannedSuites.contains(suiteName) {
                // Handle standard UserDefaults separately
                if suiteName == "standard" {
                    preferences.append(contentsOf: extractPreferences(
                        from: UserDefaults.standard,
                        suiteName: "standard",
                        config: config
                    ))
                } else if let userDefaults = UserDefaults(suiteName: suiteName) {
                    preferences.append(contentsOf: extractPreferences(
                        from: userDefaults,
                        suiteName: suiteName,
                        config: config
                    ))
                }
            }
        }

        return preferences
    }

    /// Check if a suite should be scanned based on include/exclude filters
    private func shouldScanSuite(_ suiteName: String, config: PreferencesConfiguration) -> Bool {
        // If explicitly excluded, skip
        if config.excludeUserDefaultsSuites.contains(suiteName) {
            return false
        }

        // If include list is specified, only scan those
        if !config.includeUserDefaultsSuites.isEmpty {
            return config.includeUserDefaultsSuites.contains(suiteName)
        }

        // Otherwise, scan it
        return true
    }

    // MARK: - Helper Methods

    /// Discover UserDefaults suites by scanning the Library/Preferences directory
    private func discoverUserDefaultsSuites() -> [String] {
        var discoveredSuites: [String] = []

        // Get the app's Library/Preferences directory
        guard let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return []
        }

        let preferencesPath = libraryPath.appendingPathComponent("Preferences")

        // List all .plist files in the Preferences directory
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: preferencesPath,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        for fileURL in fileURLs {
            let fileName = fileURL.lastPathComponent

            // UserDefaults .plist files follow pattern: <bundle-id>.plist or <suite-name>.plist
            if fileName.hasSuffix(".plist") {
                let suiteName = fileName.replacingOccurrences(of: ".plist", with: "")

                // Extract suite name (remove bundle ID prefix if present)
                if let bundleID = Bundle.main.bundleIdentifier,
                   suiteName.hasPrefix(bundleID) {
                    // This is a suite-based UserDefaults
                    discoveredSuites.append(suiteName)
                } else if suiteName == Bundle.main.bundleIdentifier ?? "" {
                    // This is the standard UserDefaults
                    discoveredSuites.append("standard")
                } else {
                    // Custom suite name
                    discoveredSuites.append(suiteName)
                }
            }
        }

        return discoveredSuites
    }

    /// Extract preferences from a UserDefaults instance
    private func extractPreferences(
        from userDefaults: UserDefaults,
        suiteName: String,
        config: PreferencesConfiguration
    ) -> [Preference] {
        let dictionary = userDefaults.dictionaryRepresentation()
        var preferences: [Preference] = []

        for (key, value) in dictionary {
            // Filter system keys unless configured to show them
            if !config.showSystemPreferences {
                if key.hasPrefix("Apple") || key.hasPrefix("NS") || key.hasPrefix("AK") {
                    continue
                }
            }

            let preference = Preference(
                id: UUID().uuidString,
                key: key,
                value: value,
                type: inferType(from: value),
                source: .userDefaults,
                suiteName: suiteName,
                timestamp: Date()
            )

            preferences.append(preference)
        }

        return preferences
    }

    /// Infer the type of a preference value
    private func inferType(from value: Any) -> String {
        switch value {
        case is String:
            return "String"
        case is Int, is Int32, is Int64:
            return "Integer"
        case is Bool:
            return "Boolean"
        case is Float, is Double:
            return "Float"
        case is Data:
            return "Data"
        case is [Any]:
            return "Array"
        case is [String: Any]:
            return "Dictionary"
        default:
            return "Unknown"
        }
    }
}
