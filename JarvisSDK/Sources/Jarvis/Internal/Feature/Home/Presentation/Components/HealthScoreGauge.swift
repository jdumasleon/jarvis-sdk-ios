//
//  HealthScoreGauge.swift
//  JarvisSDK
//
//  Health score gauge chart component
//

import SwiftUI
import Charts
import JarvisDesignSystem

/// Health score gauge chart with key metrics
struct HealthScoreGauge: View {
    let healthScore: HealthScore

    @State private var animatedScore: Double = 0
    @State private var animatedDisplayScore: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Health Summary".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header
                HStack {
                    Text("Overall app health score and key metrics")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)

                    Spacer()

                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }

                // Gauge Chart
                HStack(spacing: DSSpacing.l) {
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(DSColor.Neutral.neutral20, lineWidth: 12)
                            .frame(width: 150, height: 150)
                        
                        // Progress circle with fill animation
                        Circle()
                            .trim(from: 0, to: CGFloat(animatedScore / 100))
                            .stroke(
                                LinearGradient(
                                    colors: gradientColors(for: healthScore.rating),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.2), value: animatedScore)
                        
                        // Center content with animated number
                        VStack(spacing: DSSpacing.xs) {
                            Text(String(format: "%.0f", animatedDisplayScore))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(color(for: healthScore.rating))
                                .animation(.easeInOut(duration: 1.2), value: animatedDisplayScore)
                            
                            Text(healthScore.rating.displayName)
                                .dsTextStyle(.labelMedium)
                                .foregroundColor(DSColor.Neutral.neutral80)
                                .textCase(.uppercase)
                        }
                    }
                    .onAppear {
                        // Trigger fill animation from 0 to actual score
                        withAnimation(.easeInOut(duration: 1.2).delay(0.1)) {
                            animatedScore = Double(healthScore.overallScore)
                        }
                        
                        // Animate the displayed number
                        let steps = 30
                        for i in 0...steps {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.2 / Double(steps)) {
                                animatedDisplayScore = Double(healthScore.overallScore) * Double(i) / Double(steps)
                            }
                        }
                    }
                    
                    // Key Metrics Grid
                    VStack(spacing: DSSpacing.m) {
                        MetricCard(
                            icon: "number",
                            title: "Requests",
                            value: "\(healthScore.keyMetrics.totalRequests)",
                            color: DSColor.Primary.primary60
                        )
                        
                        MetricCard(
                            icon: "exclamationmark.triangle",
                            title: "Error Rate",
                            value: String(format: "%.1f%%", healthScore.keyMetrics.errorRate),
                            color: DSColor.Error.error60
                        )
                        
                        MetricCard(
                            icon: "timer",
                            title: "Avg Resp.",
                            value: String(format: "%.0fms", healthScore.keyMetrics.averageResponseTime),
                            color: DSColor.Success.success60
                        )
                        
                        MetricCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Performance",
                            value: String(format: "%.0f%%", healthScore.keyMetrics.performanceScore),
                            color: DSColor.Warning.warning60
                        )
                    }
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Helper Functions

    private func color(for rating: HealthRating) -> Color {
        Color(hex: rating.color) ?? DSColor.Neutral.neutral60
    }

    private func gradientColors(for rating: HealthRating) -> [Color] {
        let baseColor = color(for: rating)
        return [baseColor.opacity(0.6), baseColor]
    }
}

// MARK: - Metric Card

private struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: DSIconSize.xs))
                .foregroundColor(color)
            
            Text(title)
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral60)
            
            Spacer()
            
            Text(value)
                .dsTextStyle(.labelMedium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
struct HealthScoreGauge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            HealthScoreGauge(healthScore: .mock)

            HealthScoreGauge(healthScore: HealthScore(
                overallScore: 45.0,
                rating: .poor,
                keyMetrics: HealthKeyMetrics(
                    totalRequests: 150,
                    errorRate: 15.2,
                    averageResponseTime: 850.5,
                    performanceScore: 40.0,
                    networkScore: 35.0,
                    uptime: 84.8
                )
            ))
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
