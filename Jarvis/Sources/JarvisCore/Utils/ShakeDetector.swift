import Foundation
import UIKit
import SwiftUI

public class ShakeDetector: ObservableObject {
    public static let shared = ShakeDetector()
    
    @Published public var isShaking = false
    
    private var onShakeDetected: (() -> Void)?
    
    private init() {
        setupShakeDetection()
    }
    
    public func setShakeHandler(_ handler: @escaping () -> Void) {
        onShakeDetected = handler
    }
    
    private func setupShakeDetection() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceDidShake),
            name: UIDevice.deviceDidShakeNotification,
            object: nil
        )
    }
    
    @objc private func deviceDidShake() {
        #if DEBUG
        DispatchQueue.main.async {
            self.isShaking = true
            self.onShakeDetected?()
            
            // Reset after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShaking = false
            }
        }
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIDevice Extension for Shake Detection
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

// MARK: - UIWindow Extension for Shake Detection
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}