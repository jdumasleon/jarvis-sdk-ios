import Foundation
import SwiftUI
import Combine
#if os(iOS)
import CoreMotion
#endif

/// Detects device shake gestures using Core Motion
public final class ShakeDetector: ObservableObject {
    public static let shared = ShakeDetector()

    @Published public var isShaking = false

    #if os(iOS)
    private let motionManager = CMMotionManager()
    #endif
    private var shakeHandler: (() -> Void)?
    private let shakeThreshold: Double = 2.5
    private let updateInterval: TimeInterval = 0.1

    private init() {
        setupMotionManager()
    }

    deinit {
        stopDetection()
    }

    private func setupMotionManager() {
        #if os(iOS)
        guard motionManager.isAccelerometerAvailable else {
            JarvisLogger.shared.warning("Accelerometer not available for shake detection")
            return
        }

        motionManager.accelerometerUpdateInterval = updateInterval
        #else
        JarvisLogger.shared.warning("Shake detection not available on this platform")
        #endif
    }

    public func setShakeHandler(_ handler: @escaping () -> Void) {
        self.shakeHandler = handler
    }

    public func startDetection() {
        #if os(iOS)
        guard motionManager.isAccelerometerAvailable else {
            JarvisLogger.shared.warning("Cannot start shake detection: accelerometer not available")
            return
        }

        guard !motionManager.isAccelerometerActive else {
            JarvisLogger.shared.debug("Shake detection already active")
            return
        }

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else {
                if let error = error {
                    JarvisLogger.shared.error("Accelerometer error: \(error.localizedDescription)")
                }
                return
            }

            let acceleration = data.acceleration
            let magnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )

            if magnitude > self.shakeThreshold {
                self.handleShakeDetected()
            }
        }

        JarvisLogger.shared.info("Shake detection started")
        #else
        JarvisLogger.shared.warning("Shake detection not available on this platform")
        #endif
    }

    public func stopDetection() {
        #if os(iOS)
        guard motionManager.isAccelerometerActive else {
            return
        }

        motionManager.stopAccelerometerUpdates()
        JarvisLogger.shared.info("Shake detection stopped")
        #endif
    }

    private func handleShakeDetected() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.isShaking = true
            self.shakeHandler?()

            // Reset the shake state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShaking = false
            }
        }
    }
}

/// SwiftUI ViewModifier for shake detection
public struct ShakeDetectorModifier: ViewModifier {
    @StateObject private var shakeDetector = ShakeDetector.shared
    let onShakeDetected: () -> Void

    public func body(content: Content) -> some View {
        content
            .onReceive(shakeDetector.$isShaking) { isShaking in
                if isShaking {
                    onShakeDetected()
                }
            }
            .onAppear {
                shakeDetector.startDetection()
            }
            .onDisappear {
                shakeDetector.stopDetection()
            }
    }
}

public extension View {
    /// Add shake detection to any view
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetectorModifier(onShakeDetected: action))
    }
}