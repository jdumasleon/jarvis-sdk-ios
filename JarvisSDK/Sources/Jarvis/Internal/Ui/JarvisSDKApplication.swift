//
//  JarvisSDKApplication.swift
//  Jarvis
//
//  Main Jarvis SDK application with coordinator-based navigation
//

import SwiftUI
import JarvisDesignSystem
import JarvisResources

/// Main Jarvis SDK Application with coordinator-based navigation
@MainActor
public struct JarvisSDKApplication: View {
    @StateObject private var coordinator = AppCoordinator()

    let onDismiss: () -> Void
    let initialTab: AppCoordinator.Tab

    public init(
        onDismiss: @escaping () -> Void = {},
        initialTab: AppCoordinator.Tab = .home
    ) {
        self.onDismiss = onDismiss
        self.initialTab = initialTab
    }

    public var body: some View {
        let _ = coordinator.onDismissSDK = onDismiss
        VStack(spacing: 0) {
            // Main content area
            TabView(selection: $coordinator.selectedTab) {
                // Home Tab
                coordinator.makeHomeView()
                    .tag(AppCoordinator.Tab.home)
                    .tabItem {
                        tabbarItem(
                            text: AppCoordinator.Tab.home.title,
                            image: AppCoordinator.Tab.home.icon(
                                isSelected: $coordinator.selectedTab.wrappedValue == AppCoordinator.Tab.home
                            )
                        )
                    }

                // Inspector Tab
                coordinator.makeInspectorView()
                    .tag(AppCoordinator.Tab.inspector)
                    .tabItem {
                        tabbarItem(
                            text: AppCoordinator.Tab.inspector.title,
                            image: AppCoordinator.Tab.inspector.icon(
                                isSelected: $coordinator.selectedTab.wrappedValue == AppCoordinator.Tab.inspector
                            )
                        )
                    }

                // Preferences Tab
                coordinator.makePreferencesView()
                    .tag(AppCoordinator.Tab.preferences)
                    .tabItem {
                        tabbarItem(
                            text: AppCoordinator.Tab.preferences.title,
                            image: AppCoordinator.Tab.preferences.icon(
                                isSelected: $coordinator.selectedTab.wrappedValue == AppCoordinator.Tab.preferences
                            )
                        )
                    }

                // Settings Tab
                coordinator.makeSettingsView()
                    .tag(AppCoordinator.Tab.settings)
                    .tabItem {
                        tabbarItem(
                            text: AppCoordinator.Tab.settings.title,
                            image: AppCoordinator.Tab.settings.icon(
                                isSelected: $coordinator.selectedTab.wrappedValue == AppCoordinator.Tab.settings
                            )
                        )
                    }
            }
            .accentColor(DSColor.Extra.jarvisPurple)
        }
        .background(DSColor.Extra.background0)
        .onAppear {
            coordinator.selectedTab = initialTab
        }
    }

    private func tabbarItem(text: String, image: Image) -> some View {
            VStack {
                image
                Text(text)
            }
        }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    init() {
        DependencyConfiguration.registerAll()
    }

    var body: some View {
        JarvisSDKApplication(onDismiss: {
            print("Dismiss Jarvis")
        })
    }
}
#endif
