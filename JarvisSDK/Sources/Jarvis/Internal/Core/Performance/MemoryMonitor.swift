//
//  MemoryMonitor.swift
//  JarvisSDK
//
//  Memory monitoring using Mach task_info APIs
//

import Foundation
import Darwin

/// Memory monitoring using Mach task info
final class MemoryMonitor {

    /// Get current memory metrics
    func getCurrentMetrics() -> MemoryMetrics? {
        guard let taskInfo = getTaskInfo(),
              let physicalMemory = getPhysicalMemory() else {
            return nil
        }

        // Convert to MB
        let bytesToMB: Float = 1024.0 * 1024.0

        let footprintMB = Float(taskInfo.phys_footprint) / bytesToMB
        let residentSizeMB = Float(taskInfo.resident_size) / bytesToMB
        let virtualSizeMB = Float(taskInfo.virtual_size) / bytesToMB

        // iOS doesn't have traditional heap/max like Java
        // We use footprint as "used" and physical memory limits as "max"
        let totalMemoryMB = Float(physicalMemory) / bytesToMB
        let availableMemoryMB = totalMemoryMB - footprintMB

        // Determine memory pressure
        let usagePercent = (footprintMB / totalMemoryMB) * 100
        let memoryPressure: MemoryPressure
        switch usagePercent {
        case 0..<60:
            memoryPressure = .low
        case 60..<75:
            memoryPressure = .moderate
        case 75..<90:
            memoryPressure = .high
        default:
            memoryPressure = .critical
        }

        return MemoryMetrics(
            heapUsedMB: footprintMB,
            heapTotalMB: residentSizeMB,
            heapMaxMB: totalMemoryMB,
            footprintMB: footprintMB,
            availableMemoryMB: max(0, availableMemoryMB),
            totalMemoryMB: totalMemoryMB,
            memoryPressure: memoryPressure
        )
    }

    // MARK: - Private Helpers

    private func getTaskInfo() -> task_vm_info? {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &taskInfo) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: 1) { intPointer in
                task_info(
                    mach_task_self_,
                    task_flavor_t(TASK_VM_INFO),
                    intPointer,
                    &count
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        return taskInfo
    }

    private func getPhysicalMemory() -> UInt64? {
        return ProcessInfo.processInfo.physicalMemory
    }

    /// Get memory warning level from iOS
    func getSystemMemoryPressure() -> MemoryPressure {
        // iOS provides memory warnings through NotificationCenter
        // This is a simplified approach
        let memoryPressureStatus = ProcessInfo.processInfo.thermalState

        switch memoryPressureStatus {
        case .nominal:
            return .low
        case .fair:
            return .moderate
        case .serious:
            return .high
        case .critical:
            return .critical
        @unknown default:
            return .low
        }
    }
}
