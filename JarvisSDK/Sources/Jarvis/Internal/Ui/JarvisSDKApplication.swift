//
//  JarvisSDKApplication.swift
//  Jarvis
//
//  Main Jarvis SDK application with scaffold structure
//  Includes top navigation bar, bottom tab bar, and main content area
//

import SwiftUI
import DesignSystem
import JarvisResources

/// Main Jarvis SDK Application with scaffold structure
/// Provides top navigation bar, bottom tab navigation, and content area
@MainActor
public struct JarvisSDKApplication: View {
    @State private var selectedTab: JarvisTab = .home
    @State private var navigationPath: [JarvisNavigationRoute] = []

    let onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Main content area
                TabView(selection: $selectedTab) {
                    // Home Tab
                    HomeTabView()
                        .tag(JarvisTab.home)

                    // Inspector Tab
                    InspectorTabView()
                        .tag(JarvisTab.inspector)

                    // Preferences Tab
                    PreferencesTabView()
                        .tag(JarvisTab.preferences)

                    // Settings Tab
                    SettingsTabView()
                        .tag(JarvisTab.settings)
                }

                // Bottom Tab Bar
                JarvisBottomTabBar(
                    selectedTab: $selectedTab
                )
            }
            .background(DSColor.Extra.background0)
        }
    }
}

// MARK: - Tab Views

@MainActor
private struct HomeTabView: View {
    var body: some View {
        VStack {
            HomeScreen()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.Extra.background0)
    }
}

@MainActor
private struct InspectorTabView: View {
    var body: some View {
        VStack {
            DSText(
                "Network Inspector",
                style: .headlineLarge
            )
            .padding()

            DSText(
                "Monitor network requests and responses",
                style: .bodyMedium,
                color: DSColor.Neutral.neutral80
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.Extra.background0)
    }
}

@MainActor
private struct PreferencesTabView: View {
    var body: some View {
        VStack {
            DSText(
                "Preferences",
                style: .headlineLarge
            )
            .padding()

            DSText(
                "Inspect app preferences and settings",
                style: .bodyMedium,
                color: DSColor.Neutral.neutral80
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.Extra.background0)
    }
}

@MainActor
private struct SettingsTabView: View {
    var body: some View {
        VStack {
            SettingsScreen()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.Extra.background0)
    }
}

// MARK: - Bottom Tab Bar

@MainActor
private struct JarvisBottomTabBar: View {
    @Binding var selectedTab: JarvisTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(JarvisTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .frame(height: 60)
        .background(DSColor.Extra.white)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
}

@MainActor
private struct TabBarItem: View {
    let tab: JarvisTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xxs) {
                tab.icon(isSelected: isSelected)
                    .font(.system(size: DSIconSize.m))
                    .foregroundStyle(gradient)

                DSText(
                    tab.title,
                    style: .labelSmall,
                    gradient: gradient
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
        }
    }

    private var gradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [DSColor.Neutral.neutral60, DSColor.Neutral.neutral60],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Tab Definition

enum JarvisTab: String, CaseIterable {
    case home
    case inspector
    case preferences
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .inspector: return "Inspector"
        case .preferences: return "Preferences"
        case .settings: return "Settings"
        }
    }

    func icon(isSelected: Bool) -> Image {
        switch self {
        case .home:
            return isSelected ? DSIcons.Navigation.homeFilled : DSIcons.Navigation.home
        case .inspector:
            return isSelected ? DSIcons.Jarvis.inspectorFilled : DSIcons.Jarvis.inspector
        case .preferences:
            return isSelected ? DSIcons.Jarvis.preferencesFilled : DSIcons.Jarvis.preferences
        case .settings:
            return isSelected ? DSIcons.System.settingsFilled : DSIcons.System.settings
        }
    }
}

// MARK: - Navigation

enum JarvisNavigationRoute: Hashable {
    case transactionDetail(id: String)
    case preferenceDetail(key: String)
}

// MARK: - Preview

#if DEBUG
#Preview {
    JarvisSDKApplication(onDismiss: {
        print("Dismiss Jarvis")
    })
}
#endif
