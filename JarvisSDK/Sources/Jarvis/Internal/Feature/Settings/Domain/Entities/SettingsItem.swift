//
//  SettingsItem.swift
//  JarvisSDK
//
//  Settings item entities for the Settings screen
//

import Foundation

/// Represents a group of settings items in the Settings screen
public struct SettingsGroup: Identifiable {
    public let id: String
    public let title: String
    public let description: String?
    public let items: [SettingsItem]

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        items: [SettingsItem]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.items = items
    }
}

/// Represents a settings item in the Settings screen
public struct SettingsItem: Identifiable {
    public let id: String
    public let title: String
    public let description: String?
    public let value: String?
    public let icon: SettingsIcon
    public let type: SettingsItemType
    public let action: SettingsAction
    public let isEnabled: Bool

    public init(
        id: String,
        title: String,
        description: String? = nil,
        value: String? = nil,
        icon: SettingsIcon = .info,
        type: SettingsItemType = .info,
        action: SettingsAction,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.value = value
        self.icon = icon
        self.type = type
        self.action = action
        self.isEnabled = isEnabled
    }
}

/// Types of settings items
public enum SettingsItemType {
    case action          // Buttons like delete data, share
    case externalLink    // Links to external resources
    case info            // Display-only information
    case toggle          // Switch/toggle controls
    case navigate        // Navigate to another screen
}

/// Actions that can be performed from settings
public enum SettingsAction: Equatable {
    case rateApp
    case version
    case navigateToInspector
    case navigateToPreferences
    case navigateToLogging
    case showCallingAppDetails
    case openUrl(String)
    case shareApp(String)
    case openEmail(email: String, subject: String)
}

/// Icons for settings items
public enum SettingsIcon {
    case star
    case share
    case info
    case link
    case email
    case version
    case twitter
    case github
    case releaseNotes
    case logs
    case inspector
    case preferences
    case app
}
