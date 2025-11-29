//
//  HomeScreen.swift
//  JarvisSDK
//
//  Home dashboard screen with analytics
//

import SwiftUI
#if canImport(JarvisPresentation)
import JarvisPresentation
#endif
import JarvisDesignSystem
import JarvisCommon

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

// MARK: - Home Screen

public struct HomeScreen: View {
    @Environment(\.dismiss) var dismiss
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
        ZStack {
            DSColor.Extra.background0.ignoresSafeArea()

            contentView
        }
        .navigationTitle("Dashboard")
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

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        if viewModel.uiState.isLoading && viewModel.uiState.enhancedMetrics == nil {
            loadingView
        } else if let error = viewModel.uiState.error, viewModel.uiState.enhancedMetrics == nil {
            errorView(message: error.localizedDescription)
        } else {
            successView()
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: DSSpacing.m) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading dashboard...")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
    }

    // MARK: - Success View

    private func successView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // Header Content (Info Banner + Session Filter)
                if viewModel.uiState.isHeaderContentVisible {
                    // Info Banner
                    DSAlert(
                        style: .info,
                        title: "Analytics Dashboard",
                        message: "Monitor your app's performance, network activity, and preferences in real-time.") {
                            viewModel.onEvent(.dismissHeaderContent)
                        }
                }
                
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    DSText(
                        "Filter".uppercased(),
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                    .dsPadding(.horizontal, DSSpacing.m)
                    
                    // Session Filter
                    HStack(spacing: DSSpacing.s) {
                        ForEach(SessionFilter.allCases, id: \.self) { filter in
                            DSFilterChip(
                                title: filter.rawValue,
                                isSelected: viewModel.uiState.selectedSessionFilter == filter,
                                action: {
                                    viewModel.onEvent(.changeSessionFilter(filter))
                                }
                            )
                        }
                    
                    }
                }
                
                // Dashboard Cards
                if let metrics = viewModel.uiState.enhancedMetrics {
                    dashboardGrid(metrics: metrics, cardOrder: viewModel.uiState.cardOrder)
                } else {
                    emptyDashboard
                }
            }
            .dsPadding(.all, DSSpacing.m)
        }
        .refreshable {
            viewModel.onEvent(.refreshDashboard)
        }
    }

    // MARK: - Dashboard Grid

    private func dashboardGrid(metrics: EnhancedDashboardMetrics, cardOrder: [DashboardCardType]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: DSSpacing.m)
            ],
            spacing: DSSpacing.m
        ) {
            ForEach(cardOrder, id: \.self) { cardType in
                dashboardCard(for: cardType, metrics: metrics)
                    .id(cardType)
            }
        }
    }

    // MARK: - Dashboard Card

    @ViewBuilder
    private func dashboardCard(for cardType: DashboardCardType, metrics: EnhancedDashboardMetrics) -> some View {
        switch cardType {
        case .healthSummary:
            if let healthScore = metrics.healthScore {
                HealthScoreGauge(healthScore: healthScore)
            }

        case .systemPerformance:
            PerformanceOverviewChart(performanceSnapshot: metrics.performanceSnapshot)

        case .networkOverview:
            NetworkAreaChart(
                dataPoints: metrics.enhancedNetworkMetrics.requestsOverTime,
                totalRequests: metrics.enhancedNetworkMetrics.totalCalls
            )

        case .preferencesOverview:
            PreferencesOverviewChart(metrics: metrics.enhancedPreferencesMetrics)

        case .httpMethods:
            HttpMethodsDonutChart(methodData: metrics.enhancedNetworkMetrics.httpMethodDistribution)

        case .topEndpoints:
            TopEndpointsBarChart(endpoints: metrics.enhancedNetworkMetrics.topEndpoints)

        case .slowEndpoints:
            SlowestEndpointsList(endpoints: metrics.enhancedNetworkMetrics.slowestEndpoints)
        }
    }

    // MARK: - Empty Dashboard

    private var emptyDashboard: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No Data Available")
                .dsTextStyle(.headlineMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text("Start using your app to see analytics")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
                .multilineTextAlignment(.center)
        }
        .dsPadding(.all, DSSpacing.xl)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(DSColor.Error.error60)

            Text("Error Loading Dashboard")
                .dsTextStyle(.headlineMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text(message)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.onEvent(.refreshDashboard)
            }) {
                Text("Try Again")
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(DSColor.Extra.white)
                    .dsPadding(.horizontal, DSSpacing.l)
                    .dsPadding(.vertical, DSSpacing.m)
                    .background(DSColor.Primary.primary60)
                    .dsCornerRadius(DSRadius.m)
            }
        }
        .dsPadding(.all, DSSpacing.xl)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Home Screen - Loading") {
    let mockRepo = MockDashboardRepository()
    return HomeScreen(
        coordinator: HomeCoordinator(),
        viewModel: HomeViewModel(
            getEnhancedMetricsUseCase: GetEnhancedDashboardMetricsUseCase(repository: mockRepo),
            refreshMetricsUseCase: RefreshDashboardMetricsUseCase(repository: mockRepo)
        )
    )
}

#Preview("Home Screen - Success") {
    let mockRepo = MockDashboardRepository()
    return HomeScreen(
        coordinator: HomeCoordinator(),
        viewModel: HomeViewModel(
            getEnhancedMetricsUseCase: GetEnhancedDashboardMetricsUseCase(repository: mockRepo),
            refreshMetricsUseCase: RefreshDashboardMetricsUseCase(repository: mockRepo)
        )
    )
}

// MARK: - Mock Use Cases for Previews

import Combine

private class MockDashboardRepository: DashboardRepository {
    func getDashboardMetrics() -> AnyPublisher<DashboardMetrics, Error> {
        Just(DashboardMetrics(
            networkMetrics: NetworkMetrics(totalCalls: 0, averageSpeed: 0, successfulCalls: 0, failedCalls: 0, successRate: 0),
            preferencesMetrics: PreferencesMetrics(totalPreferences: 0, preferencesByType: [:], mostCommonType: nil),
            performanceMetrics: PerformanceMetrics(rating: .excellent, averageResponseTime: 0, errorRate: 0, apdexScore: 1.0)
        ))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    func getEnhancedDashboardMetrics(sessionFilter: SessionFilter) -> AnyPublisher<EnhancedDashboardMetrics, Error> {
        Just(EnhancedDashboardMetrics.mock)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func refreshMetrics() async throws -> DashboardMetrics {
        return DashboardMetrics(
            networkMetrics: NetworkMetrics(totalCalls: 0, averageSpeed: 0, successfulCalls: 0, failedCalls: 0, successRate: 0),
            preferencesMetrics: PreferencesMetrics(totalPreferences: 0, preferencesByType: [:], mostCommonType: nil),
            performanceMetrics: PerformanceMetrics(rating: .excellent, averageResponseTime: 0, errorRate: 0, apdexScore: 1.0)
        )
    }
}
#endif
