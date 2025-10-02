import SwiftUI
import JarvisDesignSystem

/// Jarvis FAB Tools module
/// Contains the floating action button tools and overlays
public struct JarvisFABTools {
    public static let version = "1.0.0"
}

// MARK: - FAB Tools Manager

@MainActor
public class FABToolsManager: ObservableObject {
    @Published public var isVisible = false
    @Published public var isExpanded = false

    public init() {}

    public func show() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isVisible = true
        }
    }

    public func hide() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded = false
            isVisible = false
        }
    }

    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
}

// MARK: - FAB Tools View

public struct FABToolsView: View {
    @StateObject public var manager = FABToolsManager()

    public let onInspectorTap: () -> Void
    public let onPreferencesTap: () -> Void
    public let onSettingsTap: () -> Void
    public let onHomeTap: () -> Void

    public init(
        onInspectorTap: @escaping () -> Void,
        onPreferencesTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onHomeTap: @escaping () -> Void
    ) {
        self.onInspectorTap = onInspectorTap
        self.onPreferencesTap = onPreferencesTap
        self.onSettingsTap = onSettingsTap
        self.onHomeTap = onHomeTap
    }

    public var body: some View {
        ZStack {
            // Background overlay when expanded
            if manager.isVisible && manager.isExpanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            manager.isExpanded = false
                        }
                    }
            }

            // FAB Tools
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    if manager.isVisible {
                        DSSpeedDialFAB(
                            mainIcon: DSIcons.Jarvis.inspector,
                            expandedIcon: DSIcons.Navigation.close,
                            actions: [
                                .init(
                                    icon: DSIcons.Navigation.home,
                                    label: "Home",
                                    action: onHomeTap
                                ),
                                .init(
                                    icon: DSIcons.Jarvis.inspector,
                                    label: "Network Inspector",
                                    action: onInspectorTap
                                ),
                                .init(
                                    icon: DSIcons.Jarvis.preferences,
                                    label: "Preferences Monitor",
                                    action: onPreferencesTap
                                ),
                                .init(
                                    icon: DSIcons.System.settings,
                                    label: "Settings",
                                    action: onSettingsTap
                                ),
                                .init(
                                    icon: DSIcons.Navigation.close,
                                    label: "Hide Jarvis",
                                    action: {
                                        manager.hide()
                                    }
                                )
                            ]
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .dsPadding(DSSpacing.m)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.isVisible)
    }
}

// MARK: - Shake Detection

public class ShakeDetector: ObservableObject {
    @Published public var isShakeDetected = false

    private var motionManager: MotionManager?

    public init() {
        setupShakeDetection()
    }

    private func setupShakeDetection() {
        #if os(iOS)
        motionManager = MotionManager()
        motionManager?.onShakeDetected = { [weak self] in
            DispatchQueue.main.async {
                self?.isShakeDetected = true
                // Reset after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.isShakeDetected = false
                }
            }
        }
        motionManager?.startShakeDetection()
        #endif
    }

    deinit {
        motionManager?.stopShakeDetection()
    }
}

// MARK: - Motion Manager (iOS specific)

#if os(iOS)
import CoreMotion

private class MotionManager {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    var onShakeDetected: (() -> Void)?

    func startShakeDetection() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let data = data, error == nil else { return }

            let acceleration = data.acceleration
            let magnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )

            // Detect shake with threshold
            if magnitude > 2.5 {
                self?.onShakeDetected?()
            }
        }
    }

    func stopShakeDetection() {
        motionManager.stopAccelerometerUpdates()
    }
}
#else
// macOS placeholder
private class MotionManager {
    var onShakeDetected: (() -> Void)?
    func startShakeDetection() {}
    func stopShakeDetection() {}
}
#endif

// MARK: - FAB Tools Container

public struct FABToolsContainer<Content: View>: View {
    let content: Content
    @StateObject private var fabManager = FABToolsManager()
    @StateObject private var shakeDetector = ShakeDetector()

    public let onInspectorTap: () -> Void
    public let onPreferencesTap: () -> Void
    public let onSettingsTap: () -> Void
    public let onHomeTap: () -> Void

    public init(
        onInspectorTap: @escaping () -> Void,
        onPreferencesTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onHomeTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onInspectorTap = onInspectorTap
        self.onPreferencesTap = onPreferencesTap
        self.onSettingsTap = onSettingsTap
        self.onHomeTap = onHomeTap
        self.content = content()
    }

    public var body: some View {
        ZStack {
            content

            FABToolsView(
                onInspectorTap: onInspectorTap,
                onPreferencesTap: onPreferencesTap,
                onSettingsTap: onSettingsTap,
                onHomeTap: onHomeTap
            )
            .environmentObject(fabManager)
        }
        .onChange(of: shakeDetector.isShakeDetected) { detected in
            if detected {
                fabManager.show()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("FAB Tools") {
    FABToolsContainer(
        onInspectorTap: { },
        onPreferencesTap: { },
        onSettingsTap: { },
        onHomeTap: { }
    ) {
        VStack {
            Text("Main App Content")
                .setTextStyle(.titleLarge)

            Text("Shake your device or tap the FAB to access Jarvis tools")
                .setTextStyle(.bodyMedium)
                .multilineTextAlignment(.center)
                .dsPadding(DSSpacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.Surface.background)
    }
}
#endif