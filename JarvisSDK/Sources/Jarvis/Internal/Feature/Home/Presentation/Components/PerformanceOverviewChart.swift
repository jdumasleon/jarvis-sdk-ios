//
//  PerformanceOverviewChart.swift
//  JarvisSDK
//
//  Performance overview chart showing CPU, Memory, and FPS metrics
//

import SwiftUI
import JarvisDesignSystem

/// Performance overview chart component showing key metrics in a compact format
struct PerformanceOverviewChart: View {
    let performanceSnapshot: PerformanceSnapshot?

    @State private var animateProgress = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            DSText(
                "Performance".uppercased(),
                style: .bodyMedium,
                color: DSColor.Neutral.neutral100
            )
            .dsPadding(.horizontal, DSSpacing.m)
            
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                // Header
                HStack {
                    Text("Real-time CPU, memory, and FPS metrics")
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
                
                ZStack(alignment: .topTrailing) {
                    Text("Avg.")
                        .dsTextStyle(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundColor(DSColor.Neutral.neutral80)

                    if let snapshot = performanceSnapshot {
                        metricsContent(snapshot: snapshot)
                    } else {
                        emptyState
                    }
                }
            }
            .dsPadding(.all, DSSpacing.m)
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(0.1)) {
                    animateProgress = true
                }
            }
        }
    }

    // MARK: - Metrics Content

    private func metricsContent(snapshot: PerformanceSnapshot) -> some View {
        HStack(spacing: DSSpacing.s) {
            // CPU Metric
            if let cpu = snapshot.cpuUsage {
                PerformanceMetricItem(
                    title: "CPU",
                    value: String(format: "%.0f%%", cpu.cpuUsagePercent),
                    icon: "speedometer",
                    color: getCpuColor(cpu.cpuUsagePercent),
                    progress: cpu.cpuUsagePercent / 100.0,
                    animate: animateProgress
                )
                .frame(maxWidth: .infinity)
            }

            // Memory Metric
            if let memory = snapshot.memoryUsage {
                PerformanceMetricItem(
                    title: "Memory",
                    value: String(format: "%.0f%%", memory.heapUsagePercent),
                    icon: "memorychip",
                    color: getMemoryColor(memory.memoryPressure),
                    progress: memory.heapUsagePercent / 100.0,
                    animate: animateProgress
                )
                .frame(maxWidth: .infinity)
            }

            // FPS Metric
            if let fps = snapshot.fpsMetrics {
                PerformanceMetricItem(
                    title: "FPS",
                    value: String(format: "%.0f", fps.currentFps),
                    icon: "waveform.path.ecg",
                    color: getFpsColor(fps.fpsStability),
                    progress: fps.currentFps / fps.refreshRate,
                    animate: animateProgress
                )
                .frame(maxWidth: .infinity)
            }
        }
        .dsPadding(.top, DSSpacing.s)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral40)

            Text("No performance data available")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Color Helpers

    private func getCpuColor(_ cpuUsage: Float) -> Color {
        switch cpuUsage {
        case 80...:
            return Color(red: 0.94, green: 0.27, blue: 0.27) // Red
        case 60..<80:
            return Color(red: 0.96, green: 0.62, blue: 0.04) // Orange
        case 40..<60:
            return Color(red: 0.92, green: 0.70, blue: 0.03) // Yellow
        default:
            return Color(red: 0.06, green: 0.72, blue: 0.51) // Green
        }
    }

    private func getMemoryColor(_ pressure: MemoryPressure) -> Color {
        switch pressure {
        case .critical:
            return Color(red: 0.94, green: 0.27, blue: 0.27) // Red
        case .high:
            return Color(red: 0.96, green: 0.62, blue: 0.04) // Orange
        case .moderate:
            return Color(red: 0.92, green: 0.70, blue: 0.03) // Yellow
        case .low:
            return Color(red: 0.06, green: 0.72, blue: 0.51) // Green
        }
    }

    private func getFpsColor(_ stability: FpsStability) -> Color {
        switch stability {
        case .excellent:
            return Color(red: 0.06, green: 0.72, blue: 0.51) // Green
        case .good:
            return Color(red: 0.92, green: 0.70, blue: 0.03) // Yellow
        case .fair:
            return Color(red: 0.96, green: 0.62, blue: 0.04) // Orange
        case .poor:
            return Color(red: 0.94, green: 0.27, blue: 0.27) // Red
        }
    }
}

// MARK: - Performance Metric Item

private struct PerformanceMetricItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Float
    let animate: Bool

    var body: some View {
        VStack(alignment: .center, spacing: DSSpacing.xs) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            // Value
            Text(value)
                .dsTextStyle(.titleLarge)
                .fontWeight(.bold)
                .foregroundColor(color)

            // Title
            Text(title)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)

            // Progress indicator with animation
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.2))
                    .frame(height: 4)

                // Progress with animated width
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(
                        width: animate ? progressWidth(progress) : 0,
                        height: 4
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func progressWidth(_ progress: Float) -> CGFloat {
        // Get available width (approximation, will be bounded by parent)
        let clampedProgress = min(max(progress, 0), 1)
        return CGFloat(clampedProgress) * 100 // Will scale with maxWidth
    }
}

// MARK: - Previews

#if DEBUG
struct PerformanceOverviewChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            PerformanceOverviewChart(
                performanceSnapshot: .mock
            )

            PerformanceOverviewChart(
                performanceSnapshot: PerformanceSnapshot(
                    cpuUsage: CpuMetrics(
                        cpuUsagePercent: 85.0,
                        appCpuUsagePercent: 40.0,
                        systemCpuUsagePercent: 45.0,
                        cores: 8,
                        threadCount: 52
                    ),
                    memoryUsage: MemoryMetrics(
                        heapUsedMB: 780.0,
                        heapTotalMB: 900.0,
                        heapMaxMB: 1024.0,
                        footprintMB: 780.0,
                        availableMemoryMB: 244.0,
                        totalMemoryMB: 1024.0,
                        memoryPressure: .high
                    ),
                    fpsMetrics: FpsMetrics(
                        currentFps: 42.0,
                        averageFps: 45.0,
                        minFps: 30.0,
                        maxFps: 60.0,
                        frameDrops: 15,
                        jankFrames: 25,
                        refreshRate: 60.0
                    ),
                    batteryLevel: 25.0,
                    thermalState: .serious
                )
            )

            PerformanceOverviewChart(
                performanceSnapshot: nil
            )
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
