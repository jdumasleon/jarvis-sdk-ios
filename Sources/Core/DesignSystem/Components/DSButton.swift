import SwiftUI

public struct DSButton: View {
    public enum Style {
        case primary
        case secondary
        case ghost
        case outline
        case destructive
        case link
    }

    public enum Size {
        case small
        case medium
        case large
        case extraLarge

        var height: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            case .extraLarge: return 64
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return DSSpacing.s
            case .medium: return DSSpacing.m
            case .large: return DSSpacing.l
            case .extraLarge: return DSSpacing.xl
            }
        }

        var textStyle: DSTextStyle {
            switch self {
            case .small: return .labelSmall
            case .medium: return .labelMedium
            case .large: return .labelLarge
            case .extraLarge: return .titleSmall
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return DSIconSize.s
            case .medium: return DSIconSize.m
            case .large: return DSIconSize.l
            case .extraLarge: return DSIconSize.xl
            }
        }
    }

    private let title: String
    private let style: Style
    private let size: Size
    private let isEnabled: Bool
    private let isLoading: Bool
    private let leftIcon: Image?
    private let rightIcon: Image?
    private let action: () -> Void

    public init(
        _ title: String,
        style: Style = .primary,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else if let leftIcon = leftIcon {
                    leftIcon
                        .font(.system(size: size.iconSize))
                        .foregroundColor(foregroundColor)
                }

                Text(title)
                    .setTextStyle(size.textStyle)
                    .foregroundColor(foregroundColor)

                if !isLoading, let rightIcon = rightIcon {
                    rightIcon
                        .font(.system(size: size.iconSize))
                        .foregroundColor(foregroundColor)
                }
            }
            .frame(height: size.height)
            .frame(maxWidth: .infinity)
            .dsPadding(.horizontal, size.horizontalPadding)
        }
        .background(backgroundColor)
        .dsCornerRadius(DSRadius.m)
        .dsBorder(borderColor, width: borderWidth)
        .disabled(!isEnabled || isLoading)
        .opacity((!isEnabled || isLoading) ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DSColor.Interactive.primary
        case .secondary:
            return DSColor.Interactive.secondary
        case .ghost:
            return DSColor.Interactive.ghost
        case .outline:
            return DSColor.Surface.surface
        case .destructive:
            return DSColor.Error.error100
        case .link:
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .destructive:
            return DSColor.Text.onPrimary
        case .ghost, .outline:
            return DSColor.Text.primary
        case .link:
            return DSColor.Text.link
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return DSColor.Surface.border
        default:
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return DSBorderWidth.regular
        default:
            return DSBorderWidth.none
        }
    }
}

// MARK: - Convenience Initializers

public extension DSButton {
    static func primary(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .primary,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }

    static func secondary(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .secondary,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }

    static func ghost(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .ghost,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }

    static func outline(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .outline,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }

    static func destructive(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .destructive,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }

    static func link(
        _ title: String,
        size: Size = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        leftIcon: Image? = nil,
        rightIcon: Image? = nil,
        action: @escaping () -> Void
    ) -> DSButton {
        DSButton(
            title,
            style: .link,
            size: size,
            isEnabled: isEnabled,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            action: action
        )
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSButtonPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Button Styles") {
                    VStack(spacing: DSSpacing.m) {
                        DSButton.primary("Primary Button") { }
                        DSButton.secondary("Secondary Button") { }
                        DSButton.ghost("Ghost Button") { }
                        DSButton.outline("Outline Button") { }
                        DSButton.destructive("Destructive Button") { }
                        DSButton.link("Link Button") { }
                    }
                }

                Section("Button Sizes") {
                    VStack(spacing: DSSpacing.m) {
                        DSButton.primary("Small", size: .small) { }
                        DSButton.primary("Medium", size: .medium) { }
                        DSButton.primary("Large", size: .large) { }
                        DSButton.primary("Extra Large", size: .extraLarge) { }
                    }
                }

                Section("Button States") {
                    VStack(spacing: DSSpacing.m) {
                        DSButton.primary("Enabled Button", isEnabled: true) { }
                        DSButton.primary("Disabled Button", isEnabled: false) { }
                        DSButton.primary("Loading Button", isLoading: true) { }
                    }
                }

                Section("Buttons with Icons") {
                    VStack(spacing: DSSpacing.m) {
                        DSButton.primary(
                            "Left Icon",
                            leftIcon: DSIcons.Action.add
                        ) { }

                        DSButton.secondary(
                            "Right Icon",
                            rightIcon: DSIcons.Navigation.forward
                        ) { }

                        DSButton.outline(
                            "Both Icons",
                            leftIcon: DSIcons.Action.edit,
                            rightIcon: DSIcons.Action.share
                        ) { }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DS Buttons")
    }
}

@available(iOS 17.0, *)
#Preview("DS Buttons") {
    DSButtonPreview()
}
#endif
