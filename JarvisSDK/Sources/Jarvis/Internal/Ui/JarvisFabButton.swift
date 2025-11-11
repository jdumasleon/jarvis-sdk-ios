import SwiftUI
import JarvisDesignSystem
import Foundation
import JarvisResources

/// Draggable floating Jarvis button with expandable tool buttons
/// Replicates the Android SDK JarvisFabButton.kt behavior
@MainActor
public struct JarvisFabButton: View {
    // Callbacks
    let onInspectorTap: () -> Void
    let onPreferencesTap: () -> Void
    let onHomeTap: () -> Void
    let onCloseTap: () -> Void

    // State
    @State private var position: CGPoint = .zero
    @State private var isExpanded = false
    @State private var isDragging = false
    @State private var pulseId = 0

    // Constants
    private let fabSize: CGFloat = DSDimensions.xxxxl
    private let miniFabSize: CGFloat = DSDimensions.xxl
    private let padding: CGFloat = DSSpacing.s
    
    public init(
        onInspectorTap: @escaping () -> Void,
        onPreferencesTap: @escaping () -> Void,
        onHomeTap: @escaping () -> Void,
        onCloseTap: @escaping () -> Void
    ) {
        self.onInspectorTap = onInspectorTap
        self.onPreferencesTap = onPreferencesTap
        self.onHomeTap = onHomeTap
        self.onCloseTap = onCloseTap
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(isExpanded ? 0.3 : 0.0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    .onTapGesture {
                        guard isExpanded else { return }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }
                
                miniFABs(in: geometry)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: position)
                
                mainFAB(in: geometry)
            }
            .onAppear {
                position = CGPoint(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
        }
    }

    private func mainFAB(in geometry: GeometryProxy) -> some View {
        JarvisFABIcon(pulseId: pulseId, isExpanded: isExpanded, size: fabSize)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true

                        // Calculate new position with bounds
                        var newPosition = value.location

                        // Keep FAB within screen bounds
                        let minX = fabSize / 2
                        let maxX = geometry.size.width - fabSize / 2
                        let minY = geometry.safeAreaInsets.top + fabSize / 2
                        let maxY = geometry.size.height - geometry.safeAreaInsets.bottom - fabSize / 2

                        newPosition.x = min(max(newPosition.x, minX), maxX)
                        newPosition.y = min(max(newPosition.y, minY), maxY)

                        position = newPosition
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if !isDragging {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded.toggle()
                            }
                            pulseId += 1
                        }
                    }
            )
            .zIndex(2)
    }

    private func miniFABs(in geometry: GeometryProxy) -> some View {
        ZStack {
            miniFAB(
                icon: DSIcons.Navigation.homeFilled,
                label: "Home",
                offset: CGPoint(x: -45, y: -45),
                action: onHomeTap
            )

            miniFAB(
                icon: DSIcons.Jarvis.inspector,
                label: "Network Inspector",
                offset: CGPoint(x: 0, y: -60),
                action: onInspectorTap
            )

            miniFAB(
                icon: DSIcons.Jarvis.preferences,
                label: "Preferences Monitor",
                offset: CGPoint(x: 45, y: -45),
                action: onPreferencesTap
            )

            miniFAB(
                icon: DSIcons.Navigation.close,
                label: "Hide Jarvis",
                offset: CGPoint(x: 60, y: 0),
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                    onCloseTap()
                }
            )
        }
        .allowsHitTesting(isExpanded)
    }

    private func miniFAB(icon: Image, label: String, offset: CGPoint, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded = false
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(DSColor.Extra.white)
                    .frame(width: miniFabSize, height: miniFabSize)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                icon
                    .font(.system(size: DSDimensions.m))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .offset(x: isExpanded ? offset.x : 0, y: isExpanded ? offset.y : 0)
        .scaleEffect(isExpanded ? 1.0 : 0.3)
        .opacity(isExpanded ? 1.0 : 0.0)
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: position)
        .position(position)
    }
}


/// Main Jarvis FAB Icon with pulse animation
private struct JarvisFABIcon: View {
    let pulseId: Int
    let isExpanded: Bool
    let size: CGFloat

    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var glowAlpha: Double = 0.0
    @State private var ringRadius: CGFloat = 0.0
    @State private var ringAlpha: Double = 0.0

    var body: some View {
        ZStack {
            // Ring pulse effect with jarvisPink gradient
            if ringAlpha > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DSColor.Extra.jarvisPink.opacity(ringAlpha),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: ringRadius
                        )
                    )
                    .frame(width: ringRadius * 2, height: ringRadius * 2)
            }

            // Glow effect with jarvisBlue gradient
            if glowAlpha > 0 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DSColor.Extra.jarvisBlue.opacity(glowAlpha),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.45
                        )
                    )
                    .frame(width: size, height: size)
            }

            // Main FAB button
            ZStack {
                Circle()
                    .fill(DSColor.Extra.white)
                    .frame(width: size - 8, height: size - 8)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)

                // JARVIS text with pink to blue gradient (left to right)
                DSText(
                    "JARVIS",
                    style: .bodySmall,
                    gradient: LinearGradient(
                        colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    fontWeight: .thin
                )

                // Jarvis shape logo image with rotation animation
                Image("jarvis-shape-logo", bundle: JarvisResourcesBundle.bundle)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 1.4, height: size * 1.4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: pulseId) { _ in
            triggerPulseAnimation()
        }
        .onChange(of: isExpanded) { newValue in
            // Rotate clockwise when expanding, counter-clockwise when collapsing
            let targetRotation = newValue ? rotation + 360 : rotation - 360
            withAnimation(.easeInOut(duration: 0.3)) {
                rotation = targetRotation
            }
        }
    }

    private func triggerPulseAnimation() {
        // Don't reset rotation - let it accumulate
        scale = 1.0
        glowAlpha = 0.0
        ringAlpha = 0.0
        ringRadius = 0.0

        // Scale bounce
        withAnimation(.easeOut(duration: 0.14)) {
            scale = 1.12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
                scale = 1.0
            }
        }

        // Glow effect
        withAnimation(.easeIn(duration: 0.18)) {
            glowAlpha = 0.35
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 0.32)) {
                glowAlpha = 0.0
            }
        }

        // Ring pulse
        ringAlpha = 0.28
        withAnimation(.easeOut(duration: 0.52)) {
            ringRadius = size * 0.9
        }
        withAnimation(.linear(duration: 0.52)) {
            ringAlpha = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
            ringRadius = 0.0
        }
    }
}

#if DEBUG
#Preview("Draggable FAB") {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()

        JarvisFabButton(
            onInspectorTap: { print("Inspector tapped") },
            onPreferencesTap: { print("Preferences tapped") },
            onHomeTap: { print("Home tapped") },
            onCloseTap: { print("Close tapped") }
        )
    }
}
#endif
