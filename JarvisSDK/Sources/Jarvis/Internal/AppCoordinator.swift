//
//  AppCoordinator.swift
//  JarvisSDK
//
//  Main application coordinator managing tab navigation and feature coordinators
//

import SwiftUI
import Presentation
import Common
import DesignSystem

import JarvisInspectorPresentation

import JarvisPreferencesPresentation
import JarvisPreferencesDomain

/// Main application coordinator
/// Manages the root TabView and creates feature coordinators
@MainActor
public final class AppCoordinator: ObservableObject {
    // MARK: - Properties

    /// Currently selected tab
    @Published var selectedTab: Tab = .home

    /// Callback to dismiss the entire SDK
    var onDismissSDK: (() -> Void)?

    // MARK: - Feature Coordinators

    private lazy var homeCoordinator = HomeCoordinator()
    private lazy var inspectorCoordinator = InspectorCoordinator()
    private lazy var preferencesCoordinator = PreferencesCoordinator()
    private lazy var settingsCoordinator = SettingsCoordinator()

    // MARK: - ViewModels

    @Injected private var getSettingsItemsUseCase: GetSettingsItemsUseCase

    @Injected private var getPreferencesUseCase: GetPreferencesUseCase
    @Injected private var updatePreferenceUseCase: UpdatePreferenceUseCase
    @Injected private var deletePreferenceUseCase: DeletePreferenceUseCase

    @Injected private var getEnhancedMetricsUseCase: GetEnhancedDashboardMetricsUseCase
    @Injected private var refreshMetricsUseCase: RefreshDashboardMetricsUseCase

    private lazy var homeViewModel = HomeViewModel(
        getEnhancedMetricsUseCase: getEnhancedMetricsUseCase,
        refreshMetricsUseCase: refreshMetricsUseCase
    )
    private lazy var inspectorViewModel = NetworkInspectorViewModel()
    private lazy var preferencesViewModel = PreferencesViewModel()
    private lazy var settingsViewModel = SettingsViewModel()

    // MARK: - Initialization

    public init() {}

    // MARK: - View Builders

    func makeHomeView() -> some View {
        homeCoordinator.onDismissSDK = onDismissSDK
        return HomeNavigationView(
            coordinator: homeCoordinator,
            viewModel: homeViewModel
        )
    }

    func makeInspectorView() -> some View {
        inspectorCoordinator.onDismissSDK = onDismissSDK
        return InspectorNavigationView(
            coordinator: inspectorCoordinator,
            viewModel: inspectorViewModel
        )
    }

    func makePreferencesView() -> some View {
        preferencesCoordinator.onDismissSDK = onDismissSDK
        return PreferencesNavigationView(
            coordinator: preferencesCoordinator,
            viewModel: preferencesViewModel
        )
    }

    func makeSettingsView() -> some View {
        settingsCoordinator.onDismissSDK = onDismissSDK
        return SettingsNavigationView(
            coordinator: settingsCoordinator,
            viewModel: settingsViewModel,
            onNavigateToInspector: { [weak self] in
                self?.selectedTab = .inspector
            },
            onNavigateToPreferences: { [weak self] in
                self?.selectedTab = .preferences
            }
        )
    }
}

// MARK: - Tab Definition

extension AppCoordinator {
    public enum Tab: String, CaseIterable {
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
}
