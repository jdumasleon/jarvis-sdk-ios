//
//  SettingsScreen.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//
import SwiftUI
import DesignSystem

// MARK: - Settings View

public struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                // Monitoring settings
                Section("Monitoring") {
                    DSToggle(
                        isOn: $viewModel.isInspectorEnabled,
                        label: "Network Inspector",
                        description: "Monitor network requests and responses"
                    )
                    .onChange(of: viewModel.isInspectorEnabled) { _ in
                        viewModel.saveSettings()
                    }

                    DSToggle(
                        isOn: $viewModel.isPreferencesEnabled,
                        label: "Preferences Monitor",
                        description: "Track changes to app preferences"
                    )
                    .onChange(of: viewModel.isPreferencesEnabled) { _ in
                        viewModel.saveSettings()
                    }
                }

                // Data settings
                Section("Data Management") {
                    DSPicker(
                        selection: $viewModel.retentionDays,
                        label: "Data Retention",
                        options: [
                            (1, "1 Day"),
                            (7, "1 Week"),
                            (30, "1 Month"),
                            (90, "3 Months")
                        ]
                    )
                    .onChange(of: viewModel.retentionDays) { _ in
                        viewModel.saveSettings()
                    }

                    DSListRow(.init(
                        title: "Clear All Data",
                        subtitle: "Remove all monitoring data",
                        leadingIcon: DSIcons.Action.delete,
                        action: {
                            // Show confirmation and clear data
                        }
                    ))

                    DSListRow(.init(
                        title: "Export Data",
                        subtitle: "Export monitoring data as JSON",
                        leadingIcon: DSIcons.File.export,
                        action: {
                            // Export data
                        }
                    ))
                }

                // Notification settings
                Section("Notifications") {
                    DSToggle(
                        isOn: $viewModel.showNotifications,
                        label: "Enable Notifications",
                        description: "Show alerts for network errors and issues"
                    )
                    .onChange(of: viewModel.showNotifications) { _ in
                        viewModel.saveSettings()
                    }
                }

                // About section
                Section("About") {
                    DSListRow(.init(
                        title: "Version",
                        subtitle: JarvisSettings.version,
                        leadingIcon: DSIcons.Status.info
                    ))

                    DSListRow(.init(
                        title: "Privacy Policy",
                        subtitle: "View our privacy policy",
                        leadingIcon: DSIcons.System.security,
                        action: {
                            // Open privacy policy
                        }
                    ))

                    DSListRow(.init(
                        title: "Support",
                        subtitle: "Get help and support",
                        leadingIcon: DSIcons.Communication.message,
                        action: {
                            // Open support
                        }
                    ))
                }

                // Reset section
                Section {
                    DSButton.destructive("Reset All Settings") {
                        showResetAlert = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetSettings()
                }
            } message: {
                Text("This will reset all Jarvis settings to their default values. This action cannot be undone.")
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Settings View") {
    SettingsScreen()
}
#endif
