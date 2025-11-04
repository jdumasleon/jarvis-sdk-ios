//
//  HomeScreen.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//
import SwiftUI
import Presentation
import DesignSystem
import Common

/// Home navigation view with coordinator-based routing
@MainActor
struct HomeNavigationView: View {
    @ObservedObject private var coordinator: HomeCoordinator
    @ObservedObject private var viewModel: HomeViewModel

    init(coordinator: HomeCoordinator, viewModel: HomeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $coordinator.routes) {
            HomeScreen(coordinator: coordinator, viewModel: viewModel)
                .navigationDestination(for: HomeCoordinator.Route.self) { route in
                    EmptyView()
                }
        }
    }
}

// MARK: - Home View
public struct HomeScreen: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    let coordinator: HomeCoordinator
    @ObservedObject var viewModel: HomeViewModel

    init(
        coordinator: HomeCoordinator,
        viewModel: HomeViewModel
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.l) {
                DSAlert(
                    style: .info,
                    title: "Wealth Dashboard",
                    message: "Welcome to your comprehensive analytics overview. Track performance, monitor network activity, and optimize your app\'s health in real-time with wealth-grade insights."
                )
                .padding()
            }
            .navigationTitle("Home")
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
        }
        
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Home View") {
    HomeScreen(
        coordinator: HomeCoordinator(),
        viewModel: HomeViewModel()
    )
}
#endif
