//
//  DemoUserDefaultsManager.swift
//  JarvisDemo
//
//  Demo app's own UserDefaults manager
//

import Foundation
import Combine

/// Demo app's own UserDefaults manager
class DemoUserDefaultsManager {

    // MARK: - UserDefaults Suites (like Android's different SharedPreferences files)

    private let demoPrefs: UserDefaults
    private let userPrefs: UserDefaults
    private let appSettings: UserDefaults
    private let cacheSettings: UserDefaults

    // MARK: - Suite Names

    static let demoPrefsName = "com.jarvis.demo.prefs"
    static let userPrefsName = "com.jarvis.demo.user"
    static let appSettingsName = "com.jarvis.demo.settings"
    static let cacheSettingsName = "com.jarvis.demo.cache"

    // MARK: - Initialization

    init() {
        // Create separate UserDefaults suites (like Android's different SharedPreferences)
        self.demoPrefs = UserDefaults(suiteName: Self.demoPrefsName) ?? .standard
        self.userPrefs = UserDefaults(suiteName: Self.userPrefsName) ?? .standard
        self.appSettings = UserDefaults(suiteName: Self.appSettingsName) ?? .standard
        self.cacheSettings = UserDefaults(suiteName: Self.cacheSettingsName) ?? .standard
    }

    // MARK: - Public API

    /// Get all preferences from all suites as a combined list
    func getAllPreferences() -> [DemoPreferenceItem] {
        var allPreferences: [DemoPreferenceItem] = []

        // Get from demo prefs
        allPreferences.append(contentsOf: extractPreferences(from: demoPrefs, suite: Self.demoPrefsName))

        // Get from user prefs
        allPreferences.append(contentsOf: extractPreferences(from: userPrefs, suite: Self.userPrefsName))

        // Get from app settings
        allPreferences.append(contentsOf: extractPreferences(from: appSettings, suite: Self.appSettingsName))

        // Get from cache settings
        allPreferences.append(contentsOf: extractPreferences(from: cacheSettings, suite: Self.cacheSettingsName))

        return allPreferences.sorted { $0.key < $1.key }
    }

    /// Get all preferences as a Combine publisher
    func getAllPreferencesPublisher() -> AnyPublisher<[DemoPreferenceItem], Never> {
        // Observe UserDefaults changes and emit updated preferences
        return NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { [weak self] _ in
                self?.getAllPreferences() ?? []
            }
            .prepend(getAllPreferences()) // Emit initial value
            .eraseToAnyPublisher()
    }

    // MARK: - Setters (by suite)

    func setDemoPreference(key: String, value: Any) {
        demoPrefs.set(value, forKey: key)
    }

    func setUserPreference(key: String, value: Any) {
        userPrefs.set(value, forKey: key)
    }

    func setAppSetting(key: String, value: Any) {
        appSettings.set(value, forKey: key)
    }

    func setCacheSetting(key: String, value: Any) {
        cacheSettings.set(value, forKey: key)
    }

    // MARK: - Generate Sample Data

    func generateSampleUserDefaults() {
        // Demo Prefs
        setDemoPreference(key: "demo_string", value: "Hello Jarvis Demo")
        setDemoPreference(key: "demo_counter", value: 42)
        setDemoPreference(key: "demo_enabled", value: true)
        setDemoPreference(key: "demo_rating", value: 4.5)

        // User Prefs
        setUserPreference(key: "user_name", value: "John Doe")
        setUserPreference(key: "user_email", value: "john.doe@example.com")
        setUserPreference(key: "user_age", value: 30)
        setUserPreference(key: "is_premium", value: false)

        // App Settings
        setAppSetting(key: "theme_mode", value: "dark")
        setAppSetting(key: "notifications_enabled", value: true)
        setAppSetting(key: "auto_sync", value: true)
        setAppSetting(key: "sync_interval", value: 300)

        // Cache Settings
        setCacheSetting(key: "cache_size_mb", value: 50)
        setCacheSetting(key: "cache_enabled", value: true)
        setCacheSetting(key: "last_cache_clear", value: Date().timeIntervalSince1970)
    }

    // MARK: - Helper Methods

    private func extractPreferences(from userDefaults: UserDefaults, suite: String) -> [DemoPreferenceItem] {
        let dictionary = userDefaults.dictionaryRepresentation()

        return dictionary.compactMap { key, value in
            // Filter out system keys (starts with Apple...)
            guard !key.hasPrefix("Apple") && !key.hasPrefix("NS") else { return nil }

            return DemoPreferenceItem(
                key: key,
                value: String(describing: value),
                type: inferType(from: value),
                storageType: .userDefaults,
                suite: suite
            )
        }
    }

    private func inferType(from value: Any) -> DemoPreferenceType {
        switch value {
        case is String:
            return .string
        case is Int, is Int32, is Int64:
            return .integer
        case is Bool:
            return .boolean
        case is Float, is Double:
            return .float
        case is Data:
            return .data
        case is [Any]:
            return .array
        case is [String: Any]:
            return .dictionary
        default:
            return .string
        }
    }

    // MARK: - Access Individual Suites (for SDK registration)

    func getDemoPrefs() -> UserDefaults { return demoPrefs }
    func getUserPrefs() -> UserDefaults { return userPrefs }
    func getAppSettings() -> UserDefaults { return appSettings }
    func getCacheSettings() -> UserDefaults { return cacheSettings }
}
