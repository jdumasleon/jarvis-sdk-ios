import Foundation
import SwiftUI
import JarvisCommon
import JarvisData
import JarvisInspector

public final class Jarvis: ObservableObject {
    public static let shared = Jarvis()
    
    @Published public var isDebugModeEnabled = false
    private let shakeDetector = ShakeDetector.shared
    
    private init() {
        setupShakeDetection()
    }
    
    public func configure() {
        #if DEBUG
        JarvisLogger.shared.info("Jarvis SDK initialized in DEBUG mode")
        JarvisURLProtocol.startIntercepting()
        isDebugModeEnabled = true
        #else
        JarvisLogger.shared.info("Jarvis SDK initialized in RELEASE mode")
        #endif
    }
    
    public func enableNetworkInterception() {
        JarvisURLProtocol.startIntercepting()
        JarvisLogger.shared.info("Network interception enabled")
    }
    
    public func disableNetworkInterception() {
        JarvisURLProtocol.stopIntercepting()
        JarvisLogger.shared.info("Network interception disabled")
    }
    
    public func showInspector() -> some View {
        JarvisMainView()
    }
    
    private func setupShakeDetection() {
        shakeDetector.setShakeHandler { [weak self] in
            self?.handleShakeDetected()
        }
    }
    
    private func handleShakeDetected() {
        #if DEBUG
        JarvisLogger.shared.debug("Shake detected - Debug mode triggered")
        #endif
    }
}

public struct JarvisShakeDetectorModifier: ViewModifier {
    @StateObject private var jarvis = Jarvis.shared
    @StateObject private var shakeDetector = ShakeDetector.shared
    @State private var showingInspector = false
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showingInspector) {
                jarvis.showInspector()
            }
            .onReceive(shakeDetector.$isShaking) { isShaking in
                if isShaking && jarvis.isDebugModeEnabled {
                    showingInspector = true
                }
            }
    }
}

public extension View {
    func jarvisShakeDetector() -> some View {
        modifier(JarvisShakeDetectorModifier())
    }
}