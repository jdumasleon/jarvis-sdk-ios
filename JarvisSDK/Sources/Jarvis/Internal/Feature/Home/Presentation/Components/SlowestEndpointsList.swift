//
//  SlowestEndpointsList.swift
//  JarvisSDK
//
//  Slowest endpoints list component
//

import SwiftUI
import JarvisDesignSystem

/// Slowest endpoints list showing performance bottlenecks
struct SlowestEndpointsList: View {
    let endpoints: [SlowEndpointData]

    private var topSlowEndpoints: [SlowEndpointData] {
        Array(endpoints.prefix(10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Slowest Endpoints".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header
                HStack {
                    Text("Performance bottlenecks")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                
                if topSlowEndpoints.isEmpty {
                    celebrationState
                } else {
                    listContent
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - List Content

    private var listContent: some View {
        VStack(spacing: DSSpacing.s) {
            ForEach(Array(topSlowEndpoints.enumerated()), id: \.element.id) { index, endpoint in
                endpointCard(endpoint: endpoint, rank: index + 1)
                    .transition(.opacity.combined(with: .slide))
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                        value: endpoint.id
                    )
            }
        }
    }

    // MARK: - Endpoint Card

    private func endpointCard(endpoint: SlowEndpointData, rank: Int) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            // Header row
            HStack(spacing: DSSpacing.s) {
                // Rank
                Text("#\(rank)")
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(DSColor.Neutral.neutral60)
                    .frame(width: 30, alignment: .leading)

                // Method tag
                Text(endpoint.method)
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(methodColor(for: endpoint.method))
                    .dsPadding(.horizontal, DSSpacing.xs)
                    .dsPadding(.vertical, 2)
                    .background(methodColor(for: endpoint.method).opacity(0.1))
                    .dsCornerRadius(DSRadius.xs)

                // Endpoint
                Text(endpoint.endpoint)
                    .dsTextStyle(.bodyMedium)
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()
            }

            // Severity bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(severityColor(for: endpoint.averageResponseTime))
                        .frame(width: 4)

                    Rectangle()
                        .fill(severityColor(for: endpoint.averageResponseTime).opacity(0.1))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 4)
            .dsCornerRadius(2)

            // Metrics
            HStack(spacing: DSSpacing.m) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Avg Time")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .font(.system(size: 10))

                    Text(String(format: "%.0fms", endpoint.averageResponseTime))
                        .dsTextStyle(.labelMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("P95")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .font(.system(size: 10))

                    Text(String(format: "%.0fms", endpoint.p95ResponseTime))
                        .dsTextStyle(.labelMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Requests")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .font(.system(size: 10))

                    Text("\(endpoint.requestCount)")
                        .dsTextStyle(.labelMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Last Slow")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .font(.system(size: 10))

                    Text(formatRelativeTime(endpoint.lastSlowRequest))
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                }
            }

            // Suggestion
            if let suggestion = performanceSuggestion(for: endpoint) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 10))
                        .foregroundColor(DSColor.Warning.warning60)

                    Text(suggestion)
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                        .font(.system(size: 11))
                }
                .dsPadding(.all, DSSpacing.xs)
                .background(DSColor.Warning.warning20)
                .dsCornerRadius(DSRadius.xs)
            }
        }
        .dsPadding(.all, DSSpacing.s)
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.s)
                .stroke(severityColor(for: endpoint.averageResponseTime).opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Celebration State

    private var celebrationState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Success.success60)

            Text("Great Performance!")
                .dsTextStyle(.titleSmall)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text("No slow endpoints detected")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Functions

    private func severityColor(for responseTime: Float) -> Color {
        switch responseTime {
        case 5000...: return DSColor.Error.error60 // > 5 seconds - critical
        case 2000..<5000: return DSColor.Warning.warning60 // 2-5 seconds - warning
        case 1000..<2000: return Color.orange // 1-2 seconds - slow
        default: return DSColor.Success.success60 // < 1 second - acceptable
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

    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func performanceSuggestion(for endpoint: SlowEndpointData) -> String? {
        switch endpoint.averageResponseTime {
        case 5000...:
            return "Consider caching or optimization"
        case 2000..<5000:
            return "Review query efficiency"
        case 1000..<2000:
            return "Monitor for trends"
        default:
            return nil
        }
    }
}

// MARK: - Previews

#if DEBUG
struct SlowestEndpointsList_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            SlowestEndpointsList(
                endpoints: EnhancedNetworkMetrics.mock.slowestEndpoints
            )

            SlowestEndpointsList(
                endpoints: []
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
