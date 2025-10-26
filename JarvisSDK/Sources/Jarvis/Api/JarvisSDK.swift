import Foundation
import SwiftUI
import Combine
// Import all required modules
import Platform
import Domain
import JarvisInspectorDomain
import Common
import DesignSystem

/// Main entry point for the Jarvis SDK
@MainActor
public final class JarvisSDK: ObservableObject {

    // MARK: - Singleton
    public static let shared = JarvisSDK()

    // MARK: - Published Properties
    @Published public private(set) var isActive = false
    @Published public private(set) var isShowing = false
    @Published public private(set) var isInitialized = false

    // MARK: - Private Properties
    private var configuration = JarvisConfig()
    private let shakeDetector = ShakeDetector.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Internal State
    private var previousActiveState = false
    private var previousShowingState = false

    // MARK: - Initialization
    private init() {
        setupShakeDetection()
    }

    // MARK: - Public API

    /// Initialize the Jarvis SDK with configuration
    /// - Parameter config: Configuration for the SDK
    public func initialize(config: JarvisConfig = JarvisConfig()) async {
        if !isInitialized {
            configuration = config

            // Configure logging
            JarvisLogger.shared.configure(enableLogging: config.enableDebugLogging)

            await performInitialization()

            isShowing = false
            isInitialized = true

            JarvisLogger.shared.info("Jarvis SDK initialized successfully")
        } else {
            // Store previous states for restoration
            previousActiveState = isActive
            previousShowingState = isShowing

            // Update configuration
            configuration = config
            JarvisLogger.shared.configure(enableLogging: config.enableDebugLogging)

            JarvisLogger.shared.info("Jarvis SDK re-initialized with new configuration")
        }
    }

    /// Initialize the SDK asynchronously
    /// - Parameters:
    ///   - config: Configuration for the SDK
    ///   - completion: Optional completion handler
    public func initializeAsync(
        config: JarvisConfig = JarvisConfig(),
        completion: (() -> Void)? = nil
    ) {
        Task {
            await initialize(config: config)
            completion?()
        }
    }

    /// Activate the SDK (show FAB and enable features)
    public func activate() {
        guard isInitialized else {
            JarvisLogger.shared.warning("Cannot activate: SDK not initialized")
            return
        }

        isActive = true

        if configuration.enableShakeDetection {
            shakeDetector.startDetection()
        }

        JarvisLogger.shared.info("Jarvis SDK activated")
    }

    /// Deactivate the SDK (hide all UI and disable features)
    public func deactivate() {
        isActive = false
        hideOverlay()

        if configuration.enableShakeDetection {
            shakeDetector.stopDetection()
        }

        JarvisLogger.shared.info("Jarvis SDK deactivated")
    }

    /// Toggle SDK activation state
    /// - Returns: New activation state
    @discardableResult
    public func toggle() -> Bool {
        if isActive {
            deactivate()
        } else {
            activate()
        }
        return isActive
    }

    /// Show the main Jarvis overlay
    public func showOverlay() {
        guard isActive else {
            JarvisLogger.shared.warning("Cannot show overlay: SDK not active")
            return
        }

        isShowing = true
        JarvisLogger.shared.debug("Jarvis overlay shown")
    }

    /// Hide the main Jarvis overlay
    public func hideOverlay() {
        isShowing = false
        JarvisLogger.shared.debug("Jarvis overlay hidden")
    }

    /// Dismiss and cleanup the SDK
    public func dismiss() {
        Task {
            await performCleanup()

            isShowing = false
            isActive = false
            isInitialized = false

            JarvisLogger.shared.info("Jarvis SDK dismissed")
        }
    }

    /// Get current configuration
    public func getConfiguration() -> JarvisConfig {
        return configuration
    }

    // MARK: - SwiftUI Integration

    /// Main Jarvis SDK application view with scaffold structure
    public func mainView() -> some View {
        JarvisSDKApplication(onDismiss: {
            Task { @MainActor in
                self.hideOverlay()
            }
        })
        .environmentObject(self)
    }

    // MARK: - Private Methods

    private func setupShakeDetection() {
        shakeDetector.setShakeHandler { [weak self] in
            Task { @MainActor in
                self?.handleShakeDetected()
            }
        }
    }

    private func handleShakeDetected() {
        guard configuration.enableShakeDetection else { return }

        JarvisLogger.shared.debug("Shake detected - toggling Jarvis SDK")
        toggle()
    }

    private func performInitialization() async {
        // Initialize core systems
        await initializeCore()

        // Initialize network inspection
        if configuration.networkInspection.enableNetworkLogging {
            await initializeNetworkInspection()
        }

        // Initialize preferences monitoring
        if configuration.preferences.configuration.autoDiscoverUserDefaults {
            await initializePreferencesMonitoring()
        }

        // Restore previous states if re-initializing
        if previousActiveState {
            isActive = previousActiveState
        }
        if previousShowingState {
            isShowing = previousShowingState
        }
    }

    private func initializeCore() async {
        // TODO: Initialize core platform services
        JarvisLogger.shared.debug("Core systems initialized")
    }

    private func initializeNetworkInspection() async {
        // TODO: Initialize inspection monitoring
        JarvisLogger.shared.debug("Network inspection initialized")
    }

    private func initializePreferencesMonitoring() async {
        // TODO: Initialize preferences monitoring
        JarvisLogger.shared.debug("Preferences monitoring initialized")
    }

    private func performCleanup() async {
        // Stop network interception

        // Stop shake detection
        shakeDetector.stopDetection()

        // Clear subscriptions
        cancellables.removeAll()

        JarvisLogger.shared.debug("SDK cleanup completed")
    }
}

// MARK: - SwiftUI Extensions

/// SwiftUI ViewModifier to integrate Jarvis SDK with any view
public struct JarvisSDKModifier: ViewModifier {
    @StateObject private var jarvis = JarvisSDK.shared
    @State private var showingInspector = false

    let config: JarvisConfig

    public init(config: JarvisConfig = JarvisConfig()) {
        self.config = config
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            // Draggable FAB Overlay - Shows when Jarvis is active
            if jarvis.isActive {
                JarvisFabButton(
                    onInspectorTap: {
                        jarvis.showOverlay()
                    },
                    onPreferencesTap: {
                        jarvis.showOverlay()
                    },
                    onHomeTap: {
                        jarvis.showOverlay()
                    },
                    onCloseTap: {
                        jarvis.deactivate()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingInspector) {
            jarvis.mainView()
        }
        .onChange(of: jarvis.isShowing) { isShowing in
            showingInspector = isShowing
        }
        .onShake {
            if jarvis.isActive && config.enableShakeDetection {
                jarvis.showOverlay()
            }
        }
        .task {
            await jarvis.initialize(config: config)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: jarvis.isActive)
    }
}

public extension View {
    /// Add Jarvis SDK integration to any SwiftUI view
    /// - Parameter config: Configuration for the SDK
    /// - Returns: View with Jarvis SDK integration
    func jarvisSDK(config: JarvisConfig = JarvisConfig()) -> some View {
        modifier(JarvisSDKModifier(config: config))
    }
}
