//
//  PerformanceMetrics.swift
//  JarvisSDK
//
//  Core performance metrics data models for cross-application monitoring
//

import Foundation

/// Complete performance snapshot containing all metrics
public struct PerformanceSnapshot: Codable, Equatable {
    public let timestamp: Date
    public let cpuUsage: CpuMetrics?
    public let memoryUsage: MemoryMetrics?
    public let fpsMetrics: FpsMetrics?
    public let batteryLevel: Float?
    public let thermalState: ThermalState

    public init(
        timestamp: Date = Date(),
        cpuUsage: CpuMetrics? = nil,
        memoryUsage: MemoryMetrics? = nil,
        fpsMetrics: FpsMetrics? = nil,
        batteryLevel: Float? = nil,
        thermalState: ThermalState = .normal
    ) {
        self.timestamp = timestamp
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.fpsMetrics = fpsMetrics
        self.batteryLevel = batteryLevel
        self.thermalState = thermalState
    }
}

/// CPU usage metrics
public struct CpuMetrics: Codable, Equatable {
    public let cpuUsagePercent: Float       // 0.0 to 100.0
    public let appCpuUsagePercent: Float    // App-specific CPU usage
    public let systemCpuUsagePercent: Float // System-wide CPU usage
    public let cores: Int
    public let threadCount: Int
    public let timestamp: Date

    public init(
        cpuUsagePercent: Float,
        appCpuUsagePercent: Float,
        systemCpuUsagePercent: Float,
        cores: Int,
        threadCount: Int,
        timestamp: Date = Date()
    ) {
        self.cpuUsagePercent = cpuUsagePercent
        self.appCpuUsagePercent = appCpuUsagePercent
        self.systemCpuUsagePercent = systemCpuUsagePercent
        self.cores = cores
        self.threadCount = threadCount
        self.timestamp = timestamp
    }
}

/// Memory usage metrics
public struct MemoryMetrics: Codable, Equatable {
    public let heapUsedMB: Float
    public let heapTotalMB: Float
    public let heapMaxMB: Float
    public let footprintMB: Float           // iOS memory footprint
    public let availableMemoryMB: Float
    public let totalMemoryMB: Float
    public let memoryPressure: MemoryPressure
    public let timestamp: Date

    /// Heap usage percentage (0-100)
    public var heapUsagePercent: Float {
        guard heapMaxMB > 0 else { return 0 }
        return (heapUsedMB / heapMaxMB) * 100
    }

    /// Memory footprint percentage (0-100)
    public var footprintPercent: Float {
        guard totalMemoryMB > 0 else { return 0 }
        return (footprintMB / totalMemoryMB) * 100
    }

    public init(
        heapUsedMB: Float,
        heapTotalMB: Float,
        heapMaxMB: Float,
        footprintMB: Float,
        availableMemoryMB: Float,
        totalMemoryMB: Float,
        memoryPressure: MemoryPressure = .low,
        timestamp: Date = Date()
    ) {
        self.heapUsedMB = heapUsedMB
        self.heapTotalMB = heapTotalMB
        self.heapMaxMB = heapMaxMB
        self.footprintMB = footprintMB
        self.availableMemoryMB = availableMemoryMB
        self.totalMemoryMB = totalMemoryMB
        self.memoryPressure = memoryPressure
        self.timestamp = timestamp
    }
}

/// Frames per second metrics
public struct FpsMetrics: Codable, Equatable {
    public let currentFps: Float
    public let averageFps: Float
    public let minFps: Float
    public let maxFps: Float
    public let frameDrops: Int
    public let jankFrames: Int              // Frames that took >16.67ms (60fps threshold)
    public let refreshRate: Float
    public let timestamp: Date

    /// FPS stability rating
    public var fpsStability: FpsStability {
        switch currentFps / refreshRate {
        case 0.95...1.0:
            return .excellent
        case 0.85..<0.95:
            return .good
        case 0.70..<0.85:
            return .fair
        default:
            return .poor
        }
    }

    public init(
        currentFps: Float,
        averageFps: Float,
        minFps: Float,
        maxFps: Float,
        frameDrops: Int,
        jankFrames: Int,
        refreshRate: Float = 60.0,
        timestamp: Date = Date()
    ) {
        self.currentFps = currentFps
        self.averageFps = averageFps
        self.minFps = minFps
        self.maxFps = maxFps
        self.frameDrops = frameDrops
        self.jankFrames = jankFrames
        self.refreshRate = refreshRate
        self.timestamp = timestamp
    }
}

// MARK: - Enums

public enum MemoryPressure: String, Codable, CaseIterable {
    case low = "LOW"
    case moderate = "MODERATE"
    case high = "HIGH"
    case critical = "CRITICAL"
}

public enum ThermalState: String, Codable, CaseIterable {
    case normal = "NORMAL"
    case fair = "FAIR"
    case serious = "SERIOUS"
    case critical = "CRITICAL"
    case emergency = "EMERGENCY"
    case shutdown = "SHUTDOWN"
}

public enum FpsStability: String, Codable, CaseIterable {
    case excellent = "EXCELLENT"
    case good = "GOOD"
    case fair = "FAIR"
    case poor = "POOR"
}

// MARK: - Configuration

/// Performance monitoring configuration
public struct PerformanceConfig {
    public let enableCpuMonitoring: Bool
    public let enableMemoryMonitoring: Bool
    public let enableFpsMonitoring: Bool
    public let samplingIntervalMs: Int64
    public let maxHistorySize: Int
    public let enableBatteryMonitoring: Bool
    public let enableThermalMonitoring: Bool

    public init(
        enableCpuMonitoring: Bool = true,
        enableMemoryMonitoring: Bool = true,
        enableFpsMonitoring: Bool = true,
        samplingIntervalMs: Int64 = 1000,
        maxHistorySize: Int = 300,
        enableBatteryMonitoring: Bool = false,
        enableThermalMonitoring: Bool = false
    ) {
        self.enableCpuMonitoring = enableCpuMonitoring
        self.enableMemoryMonitoring = enableMemoryMonitoring
        self.enableFpsMonitoring = enableFpsMonitoring
        self.samplingIntervalMs = samplingIntervalMs
        self.maxHistorySize = maxHistorySize
        self.enableBatteryMonitoring = enableBatteryMonitoring
        self.enableThermalMonitoring = enableThermalMonitoring
    }
}

/// Performance alert thresholds
public struct PerformanceThresholds {
    public let cpuThreshold: Float
    public let memoryThreshold: Float
    public let fpsThreshold: Float
    public let frameDropThreshold: Int

    public init(
        cpuThreshold: Float = 80.0,
        memoryThreshold: Float = 85.0,
        fpsThreshold: Float = 45.0,
        frameDropThreshold: Int = 10
    ) {
        self.cpuThreshold = cpuThreshold
        self.memoryThreshold = memoryThreshold
        self.fpsThreshold = fpsThreshold
        self.frameDropThreshold = frameDropThreshold
    }
}

// MARK: - Mock Data

extension PerformanceSnapshot {
    static var mock: PerformanceSnapshot {
        PerformanceSnapshot(
            timestamp: Date(),
            cpuUsage: CpuMetrics(
                cpuUsagePercent: 23.5,
                appCpuUsagePercent: 8.2,
                systemCpuUsagePercent: 15.3,
                cores: 8,
                threadCount: 45
            ),
            memoryUsage: MemoryMetrics(
                heapUsedMB: 156.8,
                heapTotalMB: 512.0,
                heapMaxMB: 1024.0,
                footprintMB: 245.3,
                availableMemoryMB: 2048.0,
                totalMemoryMB: 8192.0,
                memoryPressure: .low
            ),
            fpsMetrics: FpsMetrics(
                currentFps: 58.3,
                averageFps: 56.7,
                minFps: 45.2,
                maxFps: 60.0,
                frameDrops: 3,
                jankFrames: 12,
                refreshRate: 60.0
            ),
            batteryLevel: 68.5,
            thermalState: .normal
        )
    }
}
