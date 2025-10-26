import SwiftUI

// MARK: - Floating Action Button

public struct DSFloatingActionButton: View {
    public enum Size {
        case small
        case medium
        case large

        var diameter: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 56
            case .large: return 72
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return DSIconSize.s
            case .medium: return DSIconSize.m
            case .large: return DSIconSize.l
            }
        }
    }

    public enum Style {
        case primary
        case secondary
        case surface

        var backgroundColor: Color {
            switch self {
            case .primary: return DSColor.Primary.primary100
            case .secondary: return DSColor.Secondary.secondary100
            case .surface: return DSColor.Extra.white
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary: return DSColor.Extra.white
            case .surface: return DSColor.Neutral.neutral100
            }
        }

        var shadowLevel: (color: Color, radius: CGFloat, offset: CGSize) {
            switch self {
            case .primary, .secondary: return DSElevation.Shadow.medium
            case .surface: return DSElevation.Shadow.large
            }
        }
    }

    private let icon: Image
    private let style: Style
    private let size: Size
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        icon: Image,
        style: Style = .primary,
        size: Size = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(style.foregroundColor)
        }
        .frame(width: size.diameter, height: size.diameter)
        .background(style.backgroundColor)
        .clipShape(Circle())
        .dsShadow(style.shadowLevel)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Extended FAB

public struct DSExtendedFAB: View {
    private let icon: Image?
    private let title: String
    private let style: DSFloatingActionButton.Style
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        icon: Image? = nil,
        title: String,
        style: DSFloatingActionButton.Style = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s) {
                if let icon = icon {
                    icon
                        .font(.system(size: DSIconSize.m, weight: .medium))
                        .foregroundColor(style.foregroundColor)
                }

                Text(title)
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(style.foregroundColor)
            }
            .dsPadding(.horizontal, DSSpacing.m)
            .dsPadding(.vertical, DSSpacing.s)
        }
        .background(style.backgroundColor)
        .dsCornerRadius(DSRadius.round)
        .dsShadow(style.shadowLevel)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Speed Dial FAB

public struct DSSpeedDialFAB: View {
    @State private var isExpanded = false

    public struct SpeedDialAction {
        public let id = UUID()
        public let icon: Image
        public let label: String
        public let action: () -> Void

        public init(icon: Image, label: String, action: @escaping () -> Void) {
            self.icon = icon
            self.label = label
            self.action = action
        }
    }

    private let mainIcon: Image
    private let expandedIcon: Image?
    private let actions: [SpeedDialAction]
    private let style: DSFloatingActionButton.Style

    public init(
        mainIcon: Image,
        expandedIcon: Image? = nil,
        actions: [SpeedDialAction],
        style: DSFloatingActionButton.Style = .primary
    ) {
        self.mainIcon = mainIcon
        self.expandedIcon = expandedIcon
        self.actions = actions
        self.style = style
    }

    public var body: some View {
        VStack(spacing: DSSpacing.m) {
            // Action items
            if isExpanded {
                VStack(spacing: DSSpacing.s) {
                    ForEach(Array(actions.reversed().enumerated()), id: \.element.id) { index, action in
                        HStack {
                            Spacer()

                            // Label
                            Text(action.label)
                                .dsTextStyle(.labelSmall)
                                .foregroundColor(DSColor.Neutral.neutral100)
                                .dsPadding(.horizontal, DSSpacing.s)
                                .dsPadding(.vertical, DSSpacing.xs)
                                .background(DSColor.Extra.white)
                                .dsCornerRadius(DSRadius.s)
                                .dsShadowSmall()

                            // Action button
                            DSFloatingActionButton(
                                icon: action.icon,
                                style: .surface,
                                size: .small,
                                action: {
                                    action.action()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isExpanded = false
                                    }
                                }
                            )
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.2).delay(Double(index) * 0.05), value: isExpanded)
                    }
                }
            }

            // Main FAB
            DSFloatingActionButton(
                icon: isExpanded ? (expandedIcon ?? DSIcons.Navigation.close) : mainIcon,
                style: style,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
            )
            .rotationEffect(.degrees(isExpanded ? 45 : 0))
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
        }
        .onTapGesture {
            // Close when tapping outside
            if isExpanded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded = false
                }
            }
        }
    }
}

// MARK: - FAB with Badge

public struct DSBadgedFAB: View {
    private let icon: Image
    private let badge: String?
    private let style: DSFloatingActionButton.Style
    private let size: DSFloatingActionButton.Size
    private let action: () -> Void

    public init(
        icon: Image,
        badge: String? = nil,
        style: DSFloatingActionButton.Style = .primary,
        size: DSFloatingActionButton.Size = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.badge = badge
        self.style = style
        self.size = size
        self.action = action
    }

    public var body: some View {
        ZStack {
            DSFloatingActionButton(
                icon: icon,
                style: style,
                size: size,
                action: action
            )

            if let badge = badge {
                VStack {
                    HStack {
                        Spacer()
                        DSBadge(text: badge, style: .error)
                            .scaleEffect(0.8)
                    }
                    Spacer()
                }
                .offset(x: 8, y: -8)
            }
        }
    }
}

// MARK: - Jarvis FAB Tools

public struct DSJarvisFABTools: View {
    @State private var isExpanded = false
    @Binding private var isJarvisVisible: Bool

    private let onInspectorTap: () -> Void
    private let onPreferencesTap: () -> Void
    private let onSettingsTap: () -> Void
    private let onCloseTap: () -> Void

    public init(
        isJarvisVisible: Binding<Bool>,
        onInspectorTap: @escaping () -> Void,
        onPreferencesTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void,
        onCloseTap: @escaping () -> Void
    ) {
        self._isJarvisVisible = isJarvisVisible
        self.onInspectorTap = onInspectorTap
        self.onPreferencesTap = onPreferencesTap
        self.onSettingsTap = onSettingsTap
        self.onCloseTap = onCloseTap
    }

    public var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                if isJarvisVisible {
                    DSSpeedDialFAB(
                        mainIcon: DSIcons.Jarvis.inspector,
                        expandedIcon: DSIcons.Navigation.close,
                        actions: [
                            .init(
                                icon: DSIcons.Jarvis.inspector,
                                label: "Network Inspector",
                                action: onInspectorTap
                            ),
                            .init(
                                icon: DSIcons.Jarvis.preferences,
                                label: "Preferences",
                                action: onPreferencesTap
                            ),
                            .init(
                                icon: DSIcons.System.settings,
                                label: "Settings",
                                action: onSettingsTap
                            ),
                            .init(
                                icon: DSIcons.Navigation.close,
                                label: "Close Jarvis",
                                action: onCloseTap
                            )
                        ]
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .dsPadding(DSSpacing.m)
        }
        .animation(.easeInOut(duration: 0.3), value: isJarvisVisible)
    }
}

// MARK: - Draggable FAB

public struct DSDraggableFAB: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var isDragging = false
    @State private var screenSize = CGSize.zero

    private let icon: Image
    private let style: DSFloatingActionButton.Style
    private let size: DSFloatingActionButton.Size
    private let action: () -> Void

    public init(
        icon: Image,
        style: DSFloatingActionButton.Style = .primary,
        size: DSFloatingActionButton.Size = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    public var body: some View {
        GeometryReader { geometry in
            DSFloatingActionButton(
                icon: icon,
                style: style,
                size: size,
                action: action
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        position = value.location
                    }
                    .onEnded { value in
                        isDragging = false
                        snapToEdge(in: geometry.size)
                    }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: position)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
            .onAppear {
                screenSize = geometry.size
                // Initialize position to bottom-right corner
                if position == CGPoint.zero {
                    position = CGPoint(
                        x: geometry.size.width - 80,
                        y: geometry.size.height - 150
                    )
                }
            }
            .onChange(of: geometry.size) { newSize in
                screenSize = newSize
                // Reposition if screen size changes (e.g., rotation)
                snapToEdge(in: newSize)
            }
        }
    }

    private func snapToEdge(in screenSize: CGSize) {
        let margin: CGFloat = 20

        // Snap to nearest vertical edge
        if position.x < screenSize.width / 2 {
            position.x = margin + size.diameter / 2
        } else {
            position.x = screenSize.width - margin - size.diameter / 2
        }

        // Keep within vertical bounds
        let minY = margin + size.diameter / 2
        let maxY = screenSize.height - margin - size.diameter / 2
        position.y = max(minY, min(maxY, position.y))
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSFloatingActionButtonPreview: View {
    @State private var isJarvisVisible = true

    public init() {}

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DSSpacing.l) {
                    Section("Standard FABs") {
                        HStack(spacing: DSSpacing.m) {
                            DSFloatingActionButton(
                                icon: DSIcons.Action.add,
                                style: .primary,
                                size: .small
                            ) { }

                            DSFloatingActionButton(
                                icon: DSIcons.Action.edit,
                                style: .secondary,
                                size: .medium
                            ) { }

                            DSFloatingActionButton(
                                icon: DSIcons.Action.share,
                                style: .surface,
                                size: .large
                            ) { }
                        }
                    }

                    Section("Extended FABs") {
                        VStack(spacing: DSSpacing.m) {
                            DSExtendedFAB(
                                icon: DSIcons.Action.add,
                                title: "Add Item"
                            ) { }

                            DSExtendedFAB(
                                title: "No Icon FAB"
                            ) { }
                        }
                    }

                    Section("Badged FAB") {
                        DSBadgedFAB(
                            icon: DSIcons.Communication.notification,
                            badge: "3"
                        ) { }
                    }

                    Section("Speed Dial FAB") {
                        HStack {
                            Spacer()
                            DSSpeedDialFAB(
                                mainIcon: DSIcons.Action.add,
                                actions: [
                                    .init(icon: DSIcons.Action.edit, label: "Edit") { },
                                    .init(icon: DSIcons.Action.delete, label: "Delete") { },
                                    .init(icon: DSIcons.Action.share, label: "Share") { }
                                ]
                            )
                        }
                        .frame(height: 200)
                    }

                    Spacer(minLength: 200)
                }
                .padding()
            }

            // Jarvis FAB Tools overlay
            DSJarvisFABTools(
                isJarvisVisible: $isJarvisVisible,
                onInspectorTap: { },
                onPreferencesTap: { },
                onSettingsTap: { },
                onCloseTap: {
                    isJarvisVisible = false
                }
            )
        }
        .navigationTitle("Floating Action Buttons")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Show Jarvis") {
                    isJarvisVisible = true
                }
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview("Floating Action Buttons") {
    DSFloatingActionButtonPreview()
}
#endif
