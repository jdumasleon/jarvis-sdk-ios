import SwiftUI
import JarvisDesignSystem

/// Jarvis Home module
/// Contains the main dashboard and overview screens
public struct JarvisHome {
    public static let version = "1.0.0"
}

// MARK: - Home View Model

@MainActor
public class HomeViewModel: ObservableObject {
    @Published public var inspectorStats = InspectorStats()
    @Published public var preferencesStats = PreferencesStats()
    @Published public var isLoading = false

    public init() {}

    public func loadStats() async {
        isLoading = true

        // Load inspector and preferences statistics
        // Implementation will be added later

        isLoading = false
    }
}

// MARK: - Stats Models

public struct InspectorStats {
    public let totalRequests: Int
    public let successRequests: Int
    public let errorRequests: Int
    public let averageResponseTime: TimeInterval

    public init(
        totalRequests: Int = 0,
        successRequests: Int = 0,
        errorRequests: Int = 0,
        averageResponseTime: TimeInterval = 0
    ) {
        self.totalRequests = totalRequests
        self.successRequests = successRequests
        self.errorRequests = errorRequests
        self.averageResponseTime = averageResponseTime
    }

    public var successRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(successRequests) / Double(totalRequests)
    }
}

public struct PreferencesStats {
    public let totalChanges: Int
    public let recentChanges: Int
    public let monitoredKeys: Int

    public init(
        totalChanges: Int = 0,
        recentChanges: Int = 0,
        monitoredKeys: Int = 0
    ) {
        self.totalChanges = totalChanges
        self.recentChanges = recentChanges
        self.monitoredKeys = monitoredKeys
    }
}

// MARK: - Home View

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DSSpacing.l) {
                    // Welcome section
                    DSHeaderCard(
                        title: "Jarvis Inspector",
                        subtitle: "Monitor your app's network activity and preferences"
                    ) {
                        Text("Debug and inspect your app's behavior with powerful monitoring tools.")
                            .setTextStyle(.bodySmall)
                            .foregroundColor(DSColor.Text.secondary)
                    }

                    // Inspector stats
                    DSCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                DSIcons.Jarvis.inspector
                                    .font(.system(size: DSIconSize.m))
                                    .foregroundColor(DSColor.Primary.primary100)

                                Text("Network Inspector")
                                    .setTextStyle(.titleMedium)
                                    .foregroundColor(DSColor.Text.primary)

                                Spacer()

                                DSButton.ghost("View All", size: .small) {
                                    // Navigate to inspector
                                }
                            }

                            StatsGridView(stats: viewModel.inspectorStats)
                        }
                    }

                    // Preferences stats
                    DSCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                DSIcons.Jarvis.preferences
                                    .font(.system(size: DSIconSize.m))
                                    .foregroundColor(DSColor.Secondary.secondary100)

                                Text("Preferences Monitor")
                                    .setTextStyle(.titleMedium)
                                    .foregroundColor(DSColor.Text.primary)

                                Spacer()

                                DSButton.ghost("View All", size: .small) {
                                    // Navigate to preferences
                                }
                            }

                            PreferencesStatsView(stats: viewModel.preferencesStats)
                        }
                    }

                    // Quick actions
                    DSCard(style: .outlined) {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            Text("Quick Actions")
                                .setTextStyle(.titleMedium)
                                .foregroundColor(DSColor.Text.primary)

                            VStack(spacing: DSSpacing.s) {
                                DSButton.outline("Clear Inspector Data") {
                                    // Clear inspector data
                                }

                                DSButton.outline("Clear Preferences Data") {
                                    // Clear preferences data
                                }

                                DSButton.outline("Export Data") {
                                    // Export data
                                }
                            }
                        }
                    }
                }
                .dsPadding(DSSpacing.m)
            }
            .navigationTitle("Home")
            .task {
                await viewModel.loadStats()
            }
            .refreshable {
                await viewModel.loadStats()
            }
        }
    }
}

// MARK: - Stats Grid View

private struct StatsGridView: View {
    let stats: InspectorStats

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DSSpacing.s) {
            StatCardView(
                title: "Total Requests",
                value: "\(stats.totalRequests)",
                icon: DSIcons.Status.info
            )

            StatCardView(
                title: "Success Rate",
                value: String(format: "%.1f%%", stats.successRate * 100),
                icon: DSIcons.Status.success
            )

            StatCardView(
                title: "Avg Response",
                value: String(format: "%.0fms", stats.averageResponseTime * 1000),
                icon: DSIcons.Status.loading
            )

            StatCardView(
                title: "Errors",
                value: "\(stats.errorRequests)",
                icon: DSIcons.Status.error
            )
        }
    }
}

// MARK: - Preferences Stats View

private struct PreferencesStatsView: View {
    let stats: PreferencesStats

    var body: some View {
        HStack(spacing: DSSpacing.m) {
            StatCardView(
                title: "Total Changes",
                value: "\(stats.totalChanges)",
                icon: DSIcons.Status.info
            )

            StatCardView(
                title: "Recent",
                value: "\(stats.recentChanges)",
                icon: DSIcons.Status.success
            )

            StatCardView(
                title: "Monitored Keys",
                value: "\(stats.monitoredKeys)",
                icon: DSIcons.Jarvis.monitoring
            )
        }
    }
}

// MARK: - Stat Card View

private struct StatCardView: View {
    let title: String
    let value: String
    let icon: Image

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                icon
                    .font(.system(size: DSIconSize.s))
                    .foregroundColor(DSColor.Text.secondary)

                Spacer()
            }

            Text(value)
                .setTextStyle(.titleLarge)
                .foregroundColor(DSColor.Text.primary)

            Text(title)
                .setTextStyle(.labelMedium)
                .foregroundColor(DSColor.Text.secondary)
        }
        .dsPadding(DSSpacing.s)
        .background(DSColor.Surface.backgroundSecondary)
        .dsCornerRadius(DSRadius.s)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Home View") {
    HomeView()
}
#endif