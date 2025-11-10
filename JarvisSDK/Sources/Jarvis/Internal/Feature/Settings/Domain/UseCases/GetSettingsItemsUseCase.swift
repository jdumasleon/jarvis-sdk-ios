//
//  GetSettingsItemsUseCase.swift
//  JarvisSDK
//
//  Use case to get all settings items for the Settings screen
//

import Foundation

/// Use case to get all settings items for the Settings screen
public struct GetSettingsItemsUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [SettingsGroup] {
        let settingsAppInfo = try await repository.getSettingsAppInfo()
        return getSettingsItems(settingsAppInfo: settingsAppInfo)
    }

    public func getAppInfo() async throws -> SettingsAppInfo {
        return try await repository.getSettingsAppInfo()
    }

    private func getSettingsItems(settingsAppInfo: SettingsAppInfo) -> [SettingsGroup] {
        return [
            // App Group
            SettingsGroup(
                title: "App",
                items: [
                    SettingsItem(
                        id: "calling_app_details",
                        title: settingsAppInfo.hostAppInfo.appName,
                        value: "Version \(settingsAppInfo.hostAppInfo.version)",
                        icon: .app,
                        type: .navigate,
                        action: .showCallingAppDetails
                    )
                ]
            ),

            // Jarvis Group
            SettingsGroup(
                title: "Jarvis",
                items: [
                    SettingsItem(
                        id: "version",
                        title: "Version",
                        value: "\(settingsAppInfo.sdkInfo.version) (\(settingsAppInfo.sdkInfo.buildNumber))",
                        icon: .version,
                        type: .info,
                        action: .version
                    ),
                    SettingsItem(
                        id: "docs",
                        title: "Documentation",
                        description: "View complete documentation",
                        icon: .link,
                        type: .externalLink,
                        action: .openUrl("https://jdumasleon.com/work/jarvis")
                    ),
                    SettingsItem(
                        id: "release_notes",
                        title: "Release Notes",
                        description: "What's new in this version",
                        icon: .releaseNotes,
                        type: .externalLink,
                        action: .openUrl("https://github.com/jdumasleon/jarvis-ios-sdk")
                    )
                ]
            ),

            // Tools Group
            SettingsGroup(
                title: "Tools",
                items: [
                    SettingsItem(
                        id: "inspector",
                        title: "Inspector",
                        description: "Manage network requests",
                        icon: .inspector,
                        type: .navigate,
                        action: .navigateToInspector
                    ),
                    SettingsItem(
                        id: "preferences",
                        title: "Preferences",
                        description: "Manage application preferences",
                        icon: .preferences,
                        type: .navigate,
                        action: .navigateToPreferences
                    ),
                    SettingsItem(
                        id: "logging",
                        title: "Logging (Coming soon)",
                        description: "Manage application logs",
                        icon: .logs,
                        type: .navigate,
                        action: .navigateToLogging,
                        isEnabled: false
                    )
                ]
            ),

            // Feedback Group
            SettingsGroup(
                title: "Feedback",
                items: [
                    SettingsItem(
                        id: "rate_app",
                        title: "Rate Jarvis SDK",
                        description: "Help us improve with your feedback",
                        icon: .star,
                        type: .action,
                        action: .rateApp
                    ),
                    SettingsItem(
                        id: "share_app",
                        title: "Share Jarvis SDK",
                        description: "Tell others about this tool",
                        icon: .share,
                        type: .externalLink,
                        action: .shareApp("https://jdumasleon.com/work/jarvis")
                    ),
                    SettingsItem(
                        id: "contact",
                        title: "Contact Us",
                        description: "Get support or report issues",
                        icon: .email,
                        type: .action,
                        action: .openEmail(
                            email: "jdumasleon@gmail.com",
                            subject: "Jarvis SDK Support"
                        )
                    )
                ]
            )
        ]
    }
}
