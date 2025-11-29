//
//  SettingsScreen.swift
//  JarvisSDK
//
//  Main Settings screen
//

import SwiftUI
import JarvisDesignSystem
#if canImport(JarvisPresentation)
import JarvisPresentation
#endif
import JarvisCommon

/// Settings navigation view with coordinator-based routing
@MainActor
public struct SettingsNavigationView: View {
    @ObservedObject private var coordinator: SettingsCoordinator
    @ObservedObject private var viewModel: SettingsViewModel

    let onNavigateToInspector: () -> Void
    let onNavigateToPreferences: () -> Void

    public init(
        coordinator: SettingsCoordinator,
        viewModel: SettingsViewModel,
        onNavigateToInspector: @escaping () -> Void,
        onNavigateToPreferences: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.onNavigateToInspector = onNavigateToInspector
        self.onNavigateToPreferences = onNavigateToPreferences
    }

    public var body: some View {
        NavigationStack(path: $coordinator.routes) {
            SettingsScreen(
                coordinator: coordinator,
                viewModel: viewModel,
                onNavigateToInspector: onNavigateToInspector,
                onNavigateToPreferences: onNavigateToPreferences
            )
            .navigationDestination(for: SettingsCoordinator.Route.self) { route in
                switch route {
                case .logging:
                    LoggingView()
                }
            }
        }
        .sheet(isPresented: $coordinator.showAppDetails) {
            if let appInfo = viewModel.uiState.appInfo {
                AppDetailsSheet(appInfo: appInfo) {
                    coordinator.dismissAppDetails()
                }
            }
        }
    }
}

/// Main Settings screen displaying all settings groups
public struct SettingsScreen: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let coordinator: SettingsCoordinator
    @ObservedObject var viewModel: SettingsViewModel

    @State private var showAppDetails = false

    // Navigation callbacks
    let onNavigateToInspector: () -> Void
    let onNavigateToPreferences: () -> Void
    let onNavigateToLogging: () -> Void
    
    init(
        coordinator: SettingsCoordinator,
        viewModel: SettingsViewModel,
        onNavigateToInspector: @escaping () -> Void,
        onNavigateToPreferences: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.onNavigateToInspector = onNavigateToInspector
        self.onNavigateToPreferences = onNavigateToPreferences
        self.onNavigateToLogging = { coordinator.showLogging() }
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.l, pinnedViews: []) {
                ForEach(viewModel.uiState.settingsGroups) { group in
                    settingsGroupView(group)
                }
            }
            .padding(.top, DSSpacing.m)
            .padding(.bottom, DSSpacing.l)
        }
        .background(DSColor.Extra.background0)
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                JarvisTopBarLogo()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                DSIconButton(
                    icon: DSIcons.Navigation.close,
                    style: .ghost,
                    size: .small,
                    tint: DSColor.Neutral.neutral100
                ) {
                    coordinator.onDismissSDK?()
                }
            }
            #endif
        }
        .onAppear {
            viewModel.loadSettings()
        }
        .sheet(isPresented: $showAppDetails) {
            if let appInfo = viewModel.uiState.appInfo {
                AppDetailsSheet(appInfo: appInfo) {
                    showAppDetails = false
                    viewModel.dismissAppDetails()
                }
            }
        }
        .onChange(of: viewModel.uiState.showAppDetails) { newValue in
            showAppDetails = newValue
        }
        .sheet(isPresented: Binding(
            get: { viewModel.uiState.showRatingDialog },
            set: { if !$0 { viewModel.hideRatingDialog() } }
        )) {
            RatingSheet(
                ratingData: RatingData(
                    stars: viewModel.uiState.ratingStars,
                    description: viewModel.uiState.ratingDescription,
                    isSubmitting: viewModel.uiState.isSubmittingRating
                ),
                onRatingChange: { stars in
                    viewModel.updateRatingStars(stars)
                },
                onDescriptionChange: { description in
                    viewModel.updateRatingDescription(description)
                },
                onSubmit: {
                    viewModel.submitRating()
                },
                onCancel: {
                    viewModel.hideRatingDialog()
                }
            )
        }
    }

    // MARK: - Settings Group View

    @ViewBuilder
    private func settingsGroupView(_ group: SettingsGroup) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            // Group Header
            DSText(
                group.title.uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .padding(.horizontal, DSSpacing.m)
            .padding(.top, DSSpacing.xs)

            // Group Items
            VStack(spacing: 0) {
                ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                    SettingsItemRow(item: item) {
                        handleItemTap(item)
                    }

                    if index < group.items.count - 1 {
                        Divider()
                            .padding(.leading, DSSpacing.m)
                    }
                }
            }
            .background(DSColor.Extra.white)
            .cornerRadius(DSSpacing.xs)
            .dsShadow(DSElevation.Shadow.medium)
            .padding(.horizontal, DSSpacing.m)
        }
    }

    // MARK: - Actions

    private func handleItemTap(_ item: SettingsItem) {
        guard item.isEnabled else { return }

        switch item.action {
        // Navigation actions - handled by screen
        case .navigateToInspector:
            onNavigateToInspector()
        case .navigateToPreferences:
            onNavigateToPreferences()
        case .navigateToLogging:
            onNavigateToLogging()

        // UI presentation actions - handled by screen
        case .showCallingAppDetails:
            showAppDetails = true
        case .rateApp:
            viewModel.showRatingDialog()
        case .shareApp(let url):
            shareApp(url: url)

        // Other actions - delegated to ViewModel
        case .version, .openUrl, .openEmail:
            viewModel.handleAction(item.action)
        }
    }

    private func shareApp(url: String) {
        #if canImport(UIKit)
        guard let urlToShare = URL(string: url) else {
            print("Invalid URL for sharing: \(url)")
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: [urlToShare],
            applicationActivities: nil
        )

        // Find the topmost view controller to present from
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
           let rootVC = window.rootViewController {

            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            // For iPad, need to set sourceView for popover
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = topVC.view
                popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            topVC.present(activityVC, animated: true)
        } else {
            print("Could not find view controller to present share sheet")
        }
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Settings Screen") {
    SettingsScreen(
        coordinator: SettingsCoordinator(),
        viewModel: SettingsViewModel(),
        onNavigateToInspector: { print("Navigate to Inspector") },
        onNavigateToPreferences: { print("Navigate to Preferences") }
    )
}
#endif
