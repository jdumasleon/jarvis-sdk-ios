//
//  JarvisDemoApp.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
import Jarvis
import JarvisPreferencesDomain

@main
struct JarvisDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .jarvisSDK(config: createJarvisConfig())
        }
    }

    // MARK: - Jarvis SDK Configuration

    /// Configure Jarvis SDK
    /// The SDK will automatically scan ALL UserDefaults and Keychain items from the host app
    /// No registration needed - iOS can read .plist files and query Keychain directly!
    private func createJarvisConfig() -> JarvisConfig {
        return JarvisConfig(
            preferences: PreferencesConfig(
                configuration: PreferencesConfiguration(
                    autoDiscoverUserDefaults: true, // Scan all .plist files
                    autoDiscoverKeychain: true, // Query all Keychain items
                    enablePreferenceEditing: true, // Allow editing from SDK UI
                    showSystemPreferences: false // Hide Apple*, NS* keys
                )
            ),
            networkInspection: NetworkInspectionConfig(
                enableNetworkLogging: true
            ),
            enableDebugLogging: true,
            enableShakeDetection: true
        )
    }
}
