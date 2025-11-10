//
//  NetworkAreaChart.swift
//  JarvisSDK
//
//  Network activity area chart component matching Android design
//

import SwiftUI
import Charts
import DesignSystem

/// Network activity area chart showing requests over time
struct NetworkAreaChart: View {
    let dataPoints: [TimeSeriesDataPoint]
    let totalRequests: Int

    @State private var selectedPoint: TimeSeriesDataPoint?
    @State private var showTooltip = false
    @State private var tooltipPosition: CGPoint = .zero
    @State private var animateChart = false
    @State private var indicatorX: CGFloat = 0
    @State private var hasAnimated = false

    // Calculate average
    private var averageRequests: Int {
        guard !dataPoints.isEmpty else { return 0 }
        let sum = dataPoints.map { Int($0.value) }.reduce(0, +)
        return sum / dataPoints.count
    }

    // Calculate average requests per minute
    private var averageRequestsPerMinute: Double {
        guard dataPoints.count >= 2,
              let firstPoint = dataPoints.first,
              let lastPoint = dataPoints.last else {
            return 0
        }

        let timeInterval = lastPoint.timestamp.timeIntervalSince(firstPoint.timestamp)
        let minutes = timeInterval / 60.0

        guard minutes > 0 else { return 0 }
        return Double(totalRequests) / minutes
    }

    // Calculate Y-axis values (5 labels)
    private var yAxisValues: [Int] {
        guard !dataPoints.isEmpty else { return [] }
        let maxValue = dataPoints.map { Int($0.value) }.max() ?? 0
        let minValue = dataPoints.map { Int($0.value) }.min() ?? 0
        let range = maxValue - minValue

        return [
            maxValue,
            minValue + Int(Float(range) * 0.75),
            minValue + Int(Float(range) * 0.5),
            minValue + Int(Float(range) * 0.25),
            minValue
        ]
    }

    // Time axis labels (first, middle, last)
    private var timeAxisLabels: [(String, Alignment)] {
        guard !dataPoints.isEmpty else { return [] }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        let firstIndex = 0
        let middleIndex = dataPoints.count / 2
        let lastIndex = dataPoints.count - 1

        return [
            (formatter.string(from: dataPoints[firstIndex].timestamp), .leading),
            (formatter.string(from: dataPoints[middleIndex].timestamp), .center),
            (formatter.string(from: dataPoints[lastIndex].timestamp), .trailing)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Network Analytics".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                // Header
                HStack {
                    Text("Requests timeline with detailed analytics")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                        Text("Total: \(totalRequests)")
                            .dsTextStyle(.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(DSColor.Neutral.neutral100)

                        Text("avg: \(averageRequests) req")
                            .dsTextStyle(.bodySmall)
                            .foregroundColor(DSColor.Neutral.neutral40)
                    }

                    Spacer()

                    // Trend indicator (last vs previous)
                    if dataPoints.count >= 2 {
                        let lastValue = dataPoints.last!.value
                        let prevValue = dataPoints[dataPoints.count - 2].value
                        let isUp = lastValue > prevValue

                        HStack(spacing: DSSpacing.xxxs) {
                            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 14))
                                .foregroundColor(isUp ? DSColor.Success.success100 : DSColor.Error.error100)

                            Text("\(Int(lastValue))")
                                .dsTextStyle(.bodyMedium)
                                .fontWeight(.medium)
                                .foregroundColor(DSColor.Primary.primary60)
                        }
                    }
                }

                // Chart with Y-axis
                if dataPoints.isEmpty {
                    emptyState
                } else {
                    chartView
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onAppear {
                if !hasAnimated {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        animateChart = true
                    }
                    hasAnimated = true
                }
            }
        }
    }

    // MARK: - Chart View

    private var chartView: some View {
        VStack(spacing: DSSpacing.xxxs) {
            // Chart + Y-axis
            HStack(spacing: 0) {
                // Main chart area
                ZStack(alignment: .topLeading) {
                    chartContent
                        .frame(height: 200)

                    // Tooltip overlay
                    if showTooltip, let point = selectedPoint {
                        tooltipView(for: point)
                            .position(tooltipPosition)
                    }
                }

                // Y-axis labels on the right
                if !yAxisValues.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(yAxisValues.indices, id: \.self) { index in
                            Text("\(yAxisValues[index])")
                                .dsTextStyle(.labelSmall)
                                .foregroundColor(DSColor.Neutral.neutral60)
                                .frame(maxHeight: .infinity)
                                .frame(width: 48, alignment: .center)
                        }
                    }
                    .frame(height: 200)
                    .padding(.leading, DSSpacing.xxxs)
                }
            }

            // Time axis labels
            HStack {
                ForEach(timeAxisLabels.indices, id: \.self) { index in
                    Text(timeAxisLabels[index].0)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .frame(maxWidth: .infinity, alignment: timeAxisLabels[index].1)
                }
            }
        }
    }

    private var chartContent: some View {
        Chart {
            // Area mark
            ForEach(dataPoints) { point in
                AreaMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Requests", animateChart ? point.value : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DSColor.Primary.primary60.opacity(0.3),
                            DSColor.Primary.primary60.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            // Line mark on top
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Requests", animateChart ? point.value : 0)
                )
                .foregroundStyle(DSColor.Primary.primary60)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.linear)
            }

            // Selected point indicator with border
            if let selected = selectedPoint {
                // White border
                PointMark(
                    x: .value("Time", selected.timestamp),
                    y: .value("Requests", selected.value)
                )
                .foregroundStyle(DSColor.Extra.white)
                .symbolSize(160)

                // Main point
                PointMark(
                    x: .value("Time", selected.timestamp),
                    y: .value("Requests", selected.value)
                )
                .foregroundStyle(DSColor.Primary.primary60)
                .symbolSize(100)

                // Inner highlight
                PointMark(
                    x: .value("Time", selected.timestamp),
                    y: .value("Requests", selected.value)
                )
                .foregroundStyle(DSColor.Extra.white.opacity(0.3))
                .symbolSize(40)

                // Vertical dashed line indicator 
                RuleMark(x: .value("Time", selected.timestamp))
                    .foregroundStyle(DSColor.Primary.primary60.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [10, 5]))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(DSColor.Neutral.neutral20)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleChartTap(at: value.location, in: geometry, proxy: proxy)
                            }
                            .onEnded { _ in
                                // Auto-dismiss after 4 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    withAnimation {
                                        selectedPoint = nil
                                        showTooltip = false
                                    }
                                }
                            }
                    )
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No network activity data")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tooltip

    private func tooltipView(for point: TimeSeriesDataPoint) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("\(Int(point.value)) requests")
                .dsTextStyle(.bodyLarge)
                .fontWeight(.bold)
                .foregroundColor(DSColor.Primary.primary60)

            Text(formatTooltipTime(point.timestamp))
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)

            Text("Tap to dismiss")
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral40)
                .padding(.top, 2)
        }
        .dsPadding(.all, DSSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DSColor.Extra.surface)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showTooltip)
        .onTapGesture {
            withAnimation {
                selectedPoint = nil
                showTooltip = false
            }
        }
    }

    // MARK: - Helper Functions

    private func handleChartTap(at location: CGPoint, in geometry: GeometryProxy, proxy: ChartProxy) {
        guard let plotFrameAnchor = proxy.plotFrame else { return }
        let plotFrame = geometry[plotFrameAnchor]
        let xPosition = location.x - plotFrame.origin.x

        guard let date: Date = proxy.value(atX: xPosition) else { return }

        // Find closest data point
        if let closest = dataPoints.min(by: {
            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
        }) {
            // Animate with spring (like Android)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPoint = closest
                showTooltip = true
            }

            // Calculate tooltip position with bounds checking
            let tooltipWidth: CGFloat = 140
            let tooltipHeight: CGFloat = 80

            var xPos = location.x
            var yPos = location.y - 80 // Position above the point

            // Keep tooltip within chart bounds horizontally
            if xPos - tooltipWidth / 2 < plotFrame.minX {
                xPos = plotFrame.minX + tooltipWidth / 2 + 8
            } else if xPos + tooltipWidth / 2 > plotFrame.maxX {
                xPos = plotFrame.maxX - tooltipWidth / 2 - 8
            }

            // Keep tooltip within chart bounds vertically
            if yPos - tooltipHeight / 2 < plotFrame.minY {
                yPos = location.y + 80 // Position below the point instead
            }

            tooltipPosition = CGPoint(x: xPos, y: yPos)
        }
    }

    private func formatTooltipTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#if DEBUG
struct NetworkAreaChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            NetworkAreaChart(
                dataPoints: EnhancedNetworkMetrics.mock.requestsOverTime,
                totalRequests: 247
            )

            NetworkAreaChart(
                dataPoints: [],
                totalRequests: 0
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
