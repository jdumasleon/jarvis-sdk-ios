//
//  FpsMonitor.swift
//  JarvisSDK
//
//  FPS monitoring using CADisplayLink
//

import Foundation
import QuartzCore

#if canImport(UIKit)
import UIKit
#endif

/// FPS monitoring using CADisplayLink
final class FpsMonitor {

    #if os(iOS)
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var fpsHistory: [Float] = []
    private var frameDrops: Int = 0
    private var jankFrames: Int = 0

    private let maxHistorySize: Int = 60 // Keep 1 second of history at 60fps

    var isMonitoring: Bool {
        displayLink != nil
    }

    /// Start monitoring FPS
    func startMonitoring() {
        guard displayLink == nil else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)

        lastTimestamp = CACurrentMediaTime()
        frameCount = 0
        fpsHistory.removeAll()
        frameDrops = 0
        jankFrames = 0
    }

    /// Stop monitoring FPS
    func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
    }

    /// Get current FPS metrics
    func getCurrentMetrics() -> FpsMetrics? {
        guard !fpsHistory.isEmpty else {
            return nil
        }

        let currentFps = fpsHistory.last ?? 0
        let averageFps = fpsHistory.reduce(0, +) / Float(fpsHistory.count)
        let minFps = fpsHistory.min() ?? 0
        let maxFps = fpsHistory.max() ?? 0
        let refreshRate = Float(UIScreen.main.maximumFramesPerSecond)

        return FpsMetrics(
            currentFps: currentFps,
            averageFps: averageFps,
            minFps: minFps,
            maxFps: maxFps,
            frameDrops: frameDrops,
            jankFrames: jankFrames,
            refreshRate: refreshRate
        )
    }

    // MARK: - Private Methods

    @objc private func displayLinkTick(_ link: CADisplayLink) {
        let currentTimestamp = link.timestamp
        let elapsed = currentTimestamp - lastTimestamp

        guard elapsed > 0 else { return }

        frameCount += 1

        // Calculate FPS every second
        if elapsed >= 1.0 {
            let fps = Float(frameCount) / Float(elapsed)
            fpsHistory.append(fps)

            // Limit history size
            if fpsHistory.count > maxHistorySize {
                fpsHistory.removeFirst()
            }

            // Detect frame drops (expected vs actual frames)
            let expectedFrames = Int(elapsed * Double(UIScreen.main.maximumFramesPerSecond))
            if frameCount < expectedFrames {
                frameDrops += expectedFrames - frameCount
            }

            // Detect jank (frames taking > 16.67ms for 60fps)
            let frameTime = elapsed / Double(frameCount) * 1000.0 // ms
            let targetFrameTime = 1000.0 / Double(UIScreen.main.maximumFramesPerSecond)
            if frameTime > targetFrameTime * 1.5 {
                jankFrames += 1
            }

            // Reset for next measurement
            lastTimestamp = currentTimestamp
            frameCount = 0
        }
    }

    deinit {
        stopMonitoring()
    }
    #else
    // macOS stubs
    var isMonitoring: Bool { false }
    func startMonitoring() {}
    func stopMonitoring() {}
    func getCurrentMetrics() -> FpsMetrics? { nil }
    #endif
}
