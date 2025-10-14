//
//  SettingsViewModel.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//

import SwiftUI
import Combine

// MARK: - Settings View Model

@MainActor
public class SettingsViewModel: ObservableObject {
    @Published public var isInspectorEnabled = true
    @Published public var isPreferencesEnabled = true
    @Published public var retentionDays = 7
    @Published public var showNotifications = true
    @Published public var isLoading = false

    public init() {
        loadSettings()
    }

    public func loadSettings() {
        // Load settings from storage
        // Implementation will be added later
    }

    public func saveSettings() {
        // Save settings to storage
        // Implementation will be added later
    }

    public func resetSettings() {
        isInspectorEnabled = true
        isPreferencesEnabled = true
        retentionDays = 7
        showNotifications = true
        saveSettings()
    }
}
