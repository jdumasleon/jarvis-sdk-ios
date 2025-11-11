//
//  HttpMethodsDonutChart.swift
//  JarvisSDK
//
//  HTTP methods distribution donut chart
//

import SwiftUI
import Charts
import JarvisDesignSystem

/// HTTP methods distribution donut chart
struct HttpMethodsDonutChart: View {
    let methodData: [HttpMethodData]

    @State private var animateChart = false

    var totalRequests: Int {
        methodData.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "HTTP Methods".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header
                HStack {
                    Text("Request method distribution")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                if methodData.isEmpty {
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
                withAnimation(.easeInOut(duration: 0.8).delay(0.1)) {
                    animateChart = true
                }
            }
        }
    }

    // MARK: - Chart Content

    private var chartContent: some View {
        VStack(spacing: DSSpacing.m) {
            // Donut Chart
            Chart(methodData) { data in
                SectorMark(
                    angle: .value("Count", animateChart ? data.count : 0),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(Color(hex: data.color) ?? DSColor.Primary.primary60)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartBackground { proxy in
                GeometryReader { geometry in
                    let frame = geometry[proxy.plotAreaFrame]
                    VStack(spacing: DSSpacing.xs) {
                        Text("\(animateChart ? totalRequests : 0)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(DSColor.Neutral.neutral100)
                            .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateChart)

                        Text("Total")
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral60)
                            .textCase(.uppercase)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }

            // Legend
            VStack(spacing: DSSpacing.xs) {
                ForEach(Array(methodData.enumerated()), id: \.element.id) { index, data in
                    methodRow(data: data)
                        .opacity(animateChart ? 1 : 0)
                        .offset(x: animateChart ? 0 : -20)
                        .animation(.easeOut(duration: 0.4).delay(0.3 + Double(index) * 0.1), value: animateChart)
                }
            }
        }
    }

    // MARK: - Method Row

    private func methodRow(data: HttpMethodData) -> some View {
        HStack(spacing: DSSpacing.s) {
            // Color indicator
            Circle()
                .fill(Color(hex: data.color) ?? DSColor.Primary.primary60)
                .frame(width: 12, height: 12)

            // Method name
            Text(data.method)
                .dsTextStyle(.labelMedium)
                .foregroundColor(DSColor.Neutral.neutral100)
                .frame(width: 60, alignment: .leading)

            // Count
            Text("\(data.count)")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
                .frame(width: 50, alignment: .leading)

            // Percentage
            Text(String(format: "%.1f%%", data.percentage))
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)
                .frame(width: 50, alignment: .leading)

            Spacer()

            // Average response time
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0fms", data.averageResponseTime))
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Neutral.neutral80)

                Text("avg time")
                    .dsTextStyle(.bodySmall)
                    .foregroundColor(DSColor.Neutral.neutral60)
                    .font(.system(size: 10))
            }
        }
        .dsPadding(.vertical, DSSpacing.xs)
        .dsPadding(.horizontal, DSSpacing.s)
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No HTTP method data")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
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
struct HttpMethodsDonutChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            HttpMethodsDonutChart(
                methodData: EnhancedNetworkMetrics.mock.httpMethodDistribution
            )

            HttpMethodsDonutChart(
                methodData: []
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
