//
//  CpuMonitor.swift
//  JarvisSDK
//
//  CPU monitoring using Darwin Mach APIs
//

import Foundation
import Darwin

/// CPU monitoring using Mach host statistics
final class CpuMonitor {

    private var lastCPUTime: host_cpu_load_info = host_cpu_load_info()
    private var lastTimestamp: Date = Date()

    /// Get current CPU metrics
    func getCurrentMetrics() -> CpuMetrics? {
        guard let loadInfo = getCPULoadInfo() else {
            return nil
        }

        // Calculate CPU usage
        let userTime = Double(loadInfo.cpu_ticks.0 - lastCPUTime.cpu_ticks.0)
        let systemTime = Double(loadInfo.cpu_ticks.1 - lastCPUTime.cpu_ticks.1)
        let idleTime = Double(loadInfo.cpu_ticks.2 - lastCPUTime.cpu_ticks.2)
        let niceTime = Double(loadInfo.cpu_ticks.3 - lastCPUTime.cpu_ticks.3)

        let totalTime = userTime + systemTime + idleTime + niceTime

        let cpuUsagePercent: Float
        let systemCpuPercent: Float
        let appCpuPercent: Float

        if totalTime > 0 {
            cpuUsagePercent = Float((userTime + systemTime) / totalTime * 100.0)
            systemCpuPercent = Float(systemTime / totalTime * 100.0)
            appCpuPercent = Float(userTime / totalTime * 100.0)
        } else {
            cpuUsagePercent = 0.0
            systemCpuPercent = 0.0
            appCpuPercent = 0.0
        }

        // Update last values
        lastCPUTime = loadInfo
        lastTimestamp = Date()

        return CpuMetrics(
            cpuUsagePercent: cpuUsagePercent.clamped(to: 0...100),
            appCpuUsagePercent: appCpuPercent.clamped(to: 0...100),
            systemCpuUsagePercent: systemCpuPercent.clamped(to: 0...100),
            cores: ProcessInfo.processInfo.activeProcessorCount,
            threadCount: getThreadCount()
        )
    }

    // MARK: - Private Helpers

    private func getCPULoadInfo() -> host_cpu_load_info? {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        var cpuLoadInfo = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(size)) { intPointer in
                host_statistics(
                    mach_host_self(),
                    HOST_CPU_LOAD_INFO,
                    intPointer,
                    &size
                )
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        return cpuLoadInfo
    }

    private func getThreadCount() -> Int {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)

        let result = task_threads(mach_task_self_, &threadList, &threadCount)

        guard result == KERN_SUCCESS, let threads = threadList else {
            return 0
        }

        // Free the thread list
        vm_deallocate(
            mach_task_self_,
            vm_address_t(bitPattern: threads),
            vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.size)
        )

        return Int(threadCount)
    }
}

// MARK: - Float Extension

private extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
