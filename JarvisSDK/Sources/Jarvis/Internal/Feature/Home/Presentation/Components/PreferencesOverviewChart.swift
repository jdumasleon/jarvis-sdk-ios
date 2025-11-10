//
//  PreferencesOverviewChart.swift
//  JarvisSDK
//
//  Preferences overview chart component
//

import SwiftUI
import Charts
import DesignSystem

/// Preferences overview with donut chart, storage stats, and size distribution
struct PreferencesOverviewChart: View {
    let metrics: EnhancedPreferencesMetrics

    @State private var animateChart = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Preferences".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header
                HStack {
                    Text("App preferences and storage analytics")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                if metrics.totalPreferences == 0 {
                    emptyState
                } else {
                    VStack(spacing: DSSpacing.m) {
                        // Type Distribution Donut
                        typeDistributionSection

                        Divider()

                        // Storage Stats
                        storageStatsSection

                        Divider()

                        // Size Distribution
                        sizeDistributionSection
                    }
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).delay(0.1)) {
                    animateChart = true
                }
            }
        }
    }

    // MARK: - Type Distribution Section

    private var typeDistributionSection: some View {
        HStack(alignment: .top, spacing: DSSpacing.m) {

            // Donut + texto centrado
            ZStack {
                Chart(metrics.typeDistribution) { data in
                    SectorMark(
                        angle: .value("Count", data.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(Color(hex: data.color) ?? DSColor.Primary.primary60)
                    .cornerRadius(4)
                }
                .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("\(metrics.totalPreferences)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(DSColor.Neutral.neutral100)

                    Text("Total")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .font(.system(size: 10))
                }
            }

            // Legend
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                ForEach(metrics.typeDistribution) { data in
                    HStack(spacing: DSSpacing.xs) {
                        Circle()
                            .fill(Color(hex: data.color) ?? DSColor.Primary.primary60)
                            .frame(width: 8, height: 8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.type)
                                .dsTextStyle(.labelSmall)
                                .foregroundColor(DSColor.Neutral.neutral100)

                            HStack(spacing: 4) {
                                Text("\(data.count)")
                                    .dsTextStyle(.bodySmall)
                                    .foregroundColor(DSColor.Neutral.neutral80)
                                    .font(.system(size: 11))

                                Text("•")
                                    .foregroundColor(DSColor.Neutral.neutral40)
                                    .font(.system(size: 8))

                                Text(formatBytes(data.totalSize))
                                    .dsTextStyle(.bodySmall)
                                    .foregroundColor(DSColor.Neutral.neutral60)
                                    .font(.system(size: 11))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Storage Stats Section

    private var storageStatsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Storage Usage")
                .dsTextStyle(.labelMedium)
                .foregroundColor(DSColor.Neutral.neutral80)

            HStack(spacing: DSSpacing.s) {
                statCard(
                    title: "Total Size",
                    value: formatBytes(metrics.storageUsage.totalSize),
                    icon: "externaldrive.fill"
                )

                statCard(
                    title: "Avg. Size",
                    value: formatBytes(metrics.storageUsage.averageSize),
                    icon: "chart.bar.fill"
                )

                statCard(
                    title: "Efficiency",
                    value: String(format: "%.0f%%", metrics.storageUsage.storageEfficiency),
                    icon: "gauge.medium",
                    color: efficiencyColor(metrics.storageUsage.storageEfficiency)
                )
            }
            
            if let largest = metrics.storageUsage.largestPreference {
                statCard(
                    title: "Largest",
                    value: formatBytes(largest.size),
                    subtitle: largest.key,
                    icon: "arrow.up.circle.fill"
                )
            }
        }
    }

    // MARK: - Size Distribution Section

    private var sizeDistributionSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Size Distribution")
                .dsTextStyle(.labelMedium)
                .foregroundColor(DSColor.Neutral.neutral80)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    ForEach(metrics.sizeDistribution) { data in
                        sizeChip(data: data)
                    }
                }
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        color: Color = DSColor.Primary.primary60
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)

                Text(title)
                    .dsTextStyle(.bodySmall)
                    .foregroundColor(DSColor.Neutral.neutral60)
                    .font(.system(size: 11))
            }

            Text(value)
                .dsTextStyle(.labelMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            if let subtitle = subtitle {
                Text(subtitle)
                    .dsTextStyle(.bodySmall)
                    .foregroundColor(DSColor.Neutral.neutral60)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsPadding(.all, DSSpacing.xs)
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
    }

    // MARK: - Size Chip

    private func sizeChip(data: PreferenceSizeData) -> some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(data.sizeRange)
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text("\(data.count)")
                .dsTextStyle(.titleSmall)
                .foregroundColor(DSColor.Primary.primary60)

            Text(String(format: "%.1f%%", data.percentage))
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)
                .font(.system(size: 10))
        }
        .frame(minWidth: DSDimensions.xxxxl)
        .dsPadding(.all, DSSpacing.s)
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.s)
                .stroke(DSColor.Neutral.neutral20, lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No preferences data")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Functions

    private func formatBytes(_ bytes: Int64) -> String {
        if bytes < 1024 {
            return "\(bytes)B"
        }
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1fKB", kb)
        }
        let mb = kb / 1024.0
        return String(format: "%.1fMB", mb)
    }

    private func efficiencyColor(_ efficiency: Float) -> Color {
        switch efficiency {
        case 80...: return DSColor.Success.success60
        case 60..<80: return DSColor.Warning.warning60
        default: return Color.orange
        }
    }
}

// MARK: - Color Extension

private extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Previews

#if DEBUG
struct PreferencesOverviewChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            PreferencesOverviewChart(
                metrics: EnhancedPreferencesMetrics.mock
            )

            PreferencesOverviewChart(
                metrics: EnhancedPreferencesMetrics(
                    totalPreferences: 0,
                    preferencesByType: [:],
                    mostCommonType: nil,
                    lastModified: nil,
                    typeDistribution: [],
                    sizeDistribution: [],
                    activityOverTime: [],
                    storageUsage: StorageUsageData(
                        totalSize: 0,
                        averageSize: 0,
                        largestPreference: nil,
                        storageEfficiency: 100
                    ),
                    sessionFilter: .lastSession
                )
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
