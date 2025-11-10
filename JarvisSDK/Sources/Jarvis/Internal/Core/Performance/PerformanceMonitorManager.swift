//
//  PerformanceMonitorManager.swift
//  JarvisSDK
//
//  Coordinates all performance monitoring and handles lifecycle
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

/// Performance monitoring manager that coordinates CPU, Memory, and FPS monitoring
final class PerformanceMonitorManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentSnapshot: PerformanceSnapshot?
    @Published private(set) var isMonitoring: Bool = false
    @Published private(set) var isPaused: Bool = false

    // MARK: - Private Properties

    private let cpuMonitor = CpuMonitor()
    private let memoryMonitor = MemoryMonitor()
    private let fpsMonitor = FpsMonitor()

    private var monitoringTimer: Timer?
    private var config: PerformanceConfig
    private var snapshotHistory: [PerformanceSnapshot] = []

    private let maxHistorySize: Int = 300 // 5 minutes at 1-second intervals

    // MARK: - Initialization

    init(config: PerformanceConfig = PerformanceConfig()) {
        self.config = config
    }

    // MARK: - Public Methods

    /// Start performance monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true
        isPaused = false

        // Start FPS monitoring
        if config.enableFpsMonitoring {
            fpsMonitor.startMonitoring()
        }

        // Start periodic sampling
        let interval = TimeInterval(config.samplingIntervalMs) / 1000.0
        monitoringTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.captureSnapshot()
        }

        // Capture initial snapshot
        captureSnapshot()
    }

    /// Stop performance monitoring
    func stopMonitoring() {
        guard isMonitoring else { return }

        isMonitoring = false
        isPaused = false

        monitoringTimer?.invalidate()
        monitoringTimer = nil

        fpsMonitor.stopMonitoring()

        // Clear snapshots
        snapshotHistory.removeAll()
        currentSnapshot = nil
    }

    /// Pause monitoring (when Jarvis UI opens)
    func pauseMonitoring() {
        guard isMonitoring, !isPaused else { return }

        isPaused = true

        // Stop FPS monitoring to avoid measuring SDK overhead
        fpsMonitor.stopMonitoring()

        // Keep timer running but skip captures while paused
    }

    /// Resume monitoring (when Jarvis UI closes)
    func resumeMonitoring() {
        guard isMonitoring, isPaused else { return }

        isPaused = false

        // Resume FPS monitoring
        if config.enableFpsMonitoring {
            fpsMonitor.startMonitoring()
        }

        // Capture snapshot immediately
        captureSnapshot()
    }

    /// Get snapshot history
    func getSnapshotHistory() -> [PerformanceSnapshot] {
        return snapshotHistory
    }

    /// Get average metrics from history
    func getAverageMetrics() -> PerformanceSnapshot? {
        guard !snapshotHistory.isEmpty else { return nil }

        var totalCpu: Float = 0
        var totalMemory: Float = 0
        var totalFps: Float = 0
        var cpuCount = 0
        var memoryCount = 0
        var fpsCount = 0

        for snapshot in snapshotHistory {
            if let cpu = snapshot.cpuUsage {
                totalCpu += cpu.cpuUsagePercent
                cpuCount += 1
            }
            if let memory = snapshot.memoryUsage {
                totalMemory += memory.heapUsagePercent
                memoryCount += 1
            }
            if let fps = snapshot.fpsMetrics {
                totalFps += fps.currentFps
                fpsCount += 1
            }
        }

        let avgCpu = cpuCount > 0 ? totalCpu / Float(cpuCount) : 0
        let avgMemory = memoryCount > 0 ? totalMemory / Float(memoryCount) : 0
        let avgFps = fpsCount > 0 ? totalFps / Float(fpsCount) : 0

        // Get latest values for cores, threads, etc.
        let latestSnapshot = snapshotHistory.last

        return PerformanceSnapshot(
            cpuUsage: CpuMetrics(
                cpuUsagePercent: avgCpu,
                appCpuUsagePercent: latestSnapshot?.cpuUsage?.appCpuUsagePercent ?? 0,
                systemCpuUsagePercent: latestSnapshot?.cpuUsage?.systemCpuUsagePercent ?? 0,
                cores: latestSnapshot?.cpuUsage?.cores ?? 0,
                threadCount: latestSnapshot?.cpuUsage?.threadCount ?? 0
            ),
            memoryUsage: MemoryMetrics(
                heapUsedMB: latestSnapshot?.memoryUsage?.heapUsedMB ?? 0,
                heapTotalMB: latestSnapshot?.memoryUsage?.heapTotalMB ?? 0,
                heapMaxMB: latestSnapshot?.memoryUsage?.heapMaxMB ?? 0,
                footprintMB: latestSnapshot?.memoryUsage?.footprintMB ?? 0,
                availableMemoryMB: latestSnapshot?.memoryUsage?.availableMemoryMB ?? 0,
                totalMemoryMB: latestSnapshot?.memoryUsage?.totalMemoryMB ?? 0,
                memoryPressure: latestSnapshot?.memoryUsage?.memoryPressure ?? .low
            ),
            fpsMetrics: FpsMetrics(
                currentFps: avgFps,
                averageFps: avgFps,
                minFps: latestSnapshot?.fpsMetrics?.minFps ?? 0,
                maxFps: latestSnapshot?.fpsMetrics?.maxFps ?? 0,
                frameDrops: latestSnapshot?.fpsMetrics?.frameDrops ?? 0,
                jankFrames: latestSnapshot?.fpsMetrics?.jankFrames ?? 0,
                refreshRate: latestSnapshot?.fpsMetrics?.refreshRate ?? 60
            )
        )
    }

    // MARK: - Private Methods

    private func captureSnapshot() {
        // Skip if paused
        guard !isPaused else { return }

        var cpuMetrics: CpuMetrics?
        var memoryMetrics: MemoryMetrics?
        var fpsMetrics: FpsMetrics?

        // Capture CPU metrics
        if config.enableCpuMonitoring {
            cpuMetrics = cpuMonitor.getCurrentMetrics()
        }

        // Capture Memory metrics
        if config.enableMemoryMonitoring {
            memoryMetrics = memoryMonitor.getCurrentMetrics()
        }

        // Capture FPS metrics
        if config.enableFpsMonitoring {
            fpsMetrics = fpsMonitor.getCurrentMetrics()
        }

        // Get battery level
        var batteryLevel: Float?
        #if os(iOS)
        if config.enableBatteryMonitoring {
            UIDevice.current.isBatteryMonitoringEnabled = true
            batteryLevel = UIDevice.current.batteryLevel * 100
        }
        #endif

        // Get thermal state
        var thermalState: ThermalState = .normal
        if config.enableThermalMonitoring {
            thermalState = mapThermalState(ProcessInfo.processInfo.thermalState)
        }

        // Create snapshot
        let snapshot = PerformanceSnapshot(
            cpuUsage: cpuMetrics,
            memoryUsage: memoryMetrics,
            fpsMetrics: fpsMetrics,
            batteryLevel: batteryLevel,
            thermalState: thermalState
        )

        // Update current snapshot
        currentSnapshot = snapshot

        // Add to history
        snapshotHistory.append(snapshot)

        // Limit history size
        if snapshotHistory.count > maxHistorySize {
            snapshotHistory.removeFirst()
        }
    }

    private func mapThermalState(_ state: ProcessInfo.ThermalState) -> ThermalState {
        switch state {
        case .nominal:
            return .normal
        case .fair:
            return .fair
        case .serious:
            return .serious
        case .critical:
            return .critical
        @unknown default:
            return .normal
        }
    }

    deinit {
        stopMonitoring()
    }
}
