//
//  TopEndpointsBarChart.swift
//  JarvisSDK
//
//  Top endpoints horizontal bar chart
//

import SwiftUI
import Charts
import DesignSystem

/// Top endpoints bar chart ranked by request count
struct TopEndpointsBarChart: View {
    let endpoints: [EndpointData]

    @State private var animateBars = false

    private var topEndpoints: [EndpointData] {
        Array(endpoints.prefix(10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Top Endpoints".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header
                HStack {
                    Text("Most frequently used endpoints")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                // Header
                HStack {
                    Text("by request count")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()

                    Text("\(endpoints.count) total")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                }

                if topEndpoints.isEmpty {
                    emptyState
                } else {
                    chartContent
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onAppear {
                // Trigger bar fill animations
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateBars = true
                }
            }
        }
    }

    // MARK: - Chart Content

    private var chartContent: some View {
        VStack(spacing: DSSpacing.xs) {
            ForEach(Array(topEndpoints.enumerated()), id: \.element.id) { index, endpoint in
                endpointRow(endpoint: endpoint, rank: index + 1)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                        value: endpoint.id
                    )
            }
        }
    }

    // MARK: - Endpoint Row

    private func endpointRow(endpoint: EndpointData, rank: Int) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.s) {
                // Rank badge
                Text("\(rank)")
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Extra.white)
                    .frame(width: 24, height: 24)
                    .background(rankColor(for: rank))
                    .clipShape(Circle())

                // Method tag
                Text(endpoint.method)
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(methodColor(for: endpoint.method))
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, 2)
                    .background(methodColor(for: endpoint.method).opacity(0.1))
                    .dsCornerRadius(DSRadius.s)

                // Endpoint path
                Text(endpoint.endpoint)
                    .dsTextStyle(.bodyMedium)
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                // Request count
                Text("\(endpoint.requestCount)")
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(DSColor.Neutral.neutral80)
            }

            // Bar chart with fill animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(DSColor.Neutral.neutral20)
                        .frame(height: 6)
                        .dsCornerRadius(3)

                    // Progress with animated fill
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    methodColor(for: endpoint.method),
                                    methodColor(for: endpoint.method).opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: animateBars ? barWidth(for: endpoint.requestCount, in: geometry.size.width) : 0,
                            height: 6
                        )
                        .dsCornerRadius(3)
                }
            }
            .frame(height: 6)

            // Metrics
            HStack(spacing: DSSpacing.m) {
                metricChip(
                    icon: "timer",
                    value: String(format: "%.0fms", endpoint.averageResponseTime),
                    color: DSColor.Primary.primary60
                )

                if endpoint.errorRate > 0 {
                    metricChip(
                        icon: "exclamationmark.triangle",
                        value: String(format: "%.1f%%", endpoint.errorRate),
                        color: DSColor.Error.error60
                    )
                }

                metricChip(
                    icon: "arrow.up.arrow.down",
                    value: formatBytes(endpoint.totalTraffic),
                    color: DSColor.Success.success60
                )
            }
        }
        .dsPadding(.all, DSSpacing.s)
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
    }

    // MARK: - Metric Chip

    private func metricChip(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)

            Text(value)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)
                .font(.system(size: 11))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No endpoint data")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Functions

    private func barWidth(for count: Int, in totalWidth: CGFloat) -> CGFloat {
        guard let maxCount = topEndpoints.max(by: { $0.requestCount < $1.requestCount })?.requestCount,
              maxCount > 0 else {
            return 0
        }
        return totalWidth * CGFloat(count) / CGFloat(maxCount)
    }

    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return DSColor.Neutral.neutral60
        }
    }

    private func methodColor(for method: String) -> Color {
        switch method.uppercased() {
        case "GET": return Color(red: 0.3, green: 0.69, blue: 0.31)
        case "POST": return Color(red: 0.13, green: 0.59, blue: 0.95)
        case "PUT": return Color(red: 1.0, green: 0.6, blue: 0.0)
        case "DELETE": return Color(red: 0.96, green: 0.26, blue: 0.21)
        case "PATCH": return Color(red: 0.61, green: 0.15, blue: 0.69)
        default: return DSColor.Neutral.neutral60
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1fKB", kb)
        }
        let mb = kb / 1024.0
        return String(format: "%.1fMB", mb)
    }
}

// MARK: - Previews

#if DEBUG
struct TopEndpointsBarChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            TopEndpointsBarChart(
                endpoints: EnhancedNetworkMetrics.mock.topEndpoints
            )

            TopEndpointsBarChart(
                endpoints: []
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
