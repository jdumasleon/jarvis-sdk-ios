import SwiftUI

public struct DSCard<Content: View>: View {
    public enum Style {
        case elevated
        case outlined
        case filled
        case transparent
    }

    public enum Padding {
        case none
        case small
        case medium
        case large
        case custom(EdgeInsets)

        var edgeInsets: EdgeInsets {
            switch self {
            case .none:
                return EdgeInsets.ds(0)
            case .small:
                return EdgeInsets.ds(DSSpacing.s)
            case .medium:
                return EdgeInsets.ds(DSSpacing.m)
            case .large:
                return EdgeInsets.ds(DSSpacing.l)
            case .custom(let insets):
                return insets
            }
        }
    }

    private let style: Style
    private let padding: Padding
    private let cornerRadius: CGFloat
    private let content: Content

    public init(
        style: Style = .elevated,
        padding: Padding = .medium,
        cornerRadius: CGFloat = DSRadius.m,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding.edgeInsets)
            .background(backgroundColor)
            .dsCornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.width, y: shadowOffset.height)
    }

    private var backgroundColor: Color {
        switch style {
        case .elevated, .outlined:
            return DSColor.Extra.white
        case .filled:
            return DSColor.Neutral.neutral0
        case .transparent:
            return Color.clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .outlined:
            return DSColor.Neutral.neutral20
        default:
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return DSBorderWidth.regular
        default:
            return DSBorderWidth.none
        }
    }

    private var shadowColor: Color {
        switch style {
        case .elevated:
            return DSElevation.Shadow.medium.color
        default:
            return Color.clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return DSElevation.Shadow.medium.radius
        default:
            return 0
        }
    }

    private var shadowOffset: CGSize {
        switch style {
        case .elevated:
            return DSElevation.Shadow.medium.offset
        default:
            return .zero
        }
    }
}

// MARK: - Header Card

public struct DSHeaderCard<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: AnyView?
    private let style: DSCard<AnyView>.Style
    private let content: Content?

    public init(
        title: String,
        subtitle: String? = nil,
        style: DSCard<AnyView>.Style = .elevated,
        @ViewBuilder trailing: () -> AnyView = { AnyView(EmptyView()) },
        @ViewBuilder content: () -> Content = { EmptyView() as! Content }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.trailing = trailing()
        self.content = content()
    }

    public var body: some View {
        DSCard(style: style, padding: .none) {
            AnyView(
                VStack(spacing: DSSpacing.none) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text(title)
                                .dsTextStyle(.titleMedium)
                                .foregroundColor(DSColor.Neutral.neutral100)

                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .dsTextStyle(.bodySmall)
                                    .foregroundColor(DSColor.Neutral.neutral80)
                            }
                        }

                        Spacer()

                        trailing
                    }
                    .dsPadding(DSSpacing.m)

                    // Content
                    if content is EmptyView {
                        EmptyView()
                    } else {
                        content
                            .dsPadding(.horizontal, DSSpacing.m)
                            .dsPadding(.bottom, DSSpacing.m)
                    }
                }
            )
        }
    }
}

// MARK: - List Card

public struct DSListCard: View {
    public struct Item {
        public let title: String
        public let subtitle: String?
        public let trailing: AnyView?
        public let leadingIcon: Image?
        public let action: (() -> Void)?

        public init(
            title: String,
            subtitle: String? = nil,
            leadingIcon: Image? = nil,
            trailing: AnyView? = nil,
            action: (() -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.leadingIcon = leadingIcon
            self.trailing = trailing
            self.action = action
        }
    }

    private let items: [Item]
    private let style: DSCard<AnyView>.Style

    public init(
        items: [Item],
        style: DSCard<AnyView>.Style = .elevated
    ) {
        self.items = items
        self.style = style
    }

    public var body: some View {
        DSCard(style: style, padding: .none) {
            AnyView(
                VStack(spacing: DSSpacing.none) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        DSListItem(
                            title: item.title,
                            subtitle: item.subtitle,
                            leadingIcon: item.leadingIcon,
                            trailing: item.trailing,
                            action: item.action
                        )

                        if index < items.count - 1 {
                            Divider()
                                .background(DSColor.Neutral.neutral20)
                                .dsPadding(.horizontal, DSSpacing.m)
                        }
                    }
                }
            )
        }
    }
}

// MARK: - List Item

public struct DSListItem: View {
    private let title: String
    private let subtitle: String?
    private let leadingIcon: Image?
    private let trailing: AnyView?
    private let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: Image? = nil,
        trailing: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.trailing = trailing
        self.action = action
    }

    public var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DSSpacing.s) {
                // Leading icon
                if let leadingIcon = leadingIcon {
                    leadingIcon
                        .font(.system(size: DSIconSize.m))
                        .foregroundColor(DSColor.Neutral.neutral80)
                        .frame(width: DSIconSize.l, height: DSIconSize.l)
                }

                // Content
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(title)
                        .dsTextStyle(.bodyMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Trailing content
                if let trailing = trailing {
                    trailing
                } else if action != nil {
                    DSIcons.Navigation.forward
                        .font(.system(size: DSIconSize.s))
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
            }
            .dsPadding(DSSpacing.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - Status Card

public struct DSStatusCard: View {
    public enum Status {
        case success
        case warning
        case error
        case info
        case neutral

        var color: Color {
            switch self {
            case .success: return DSColor.Success.success100
            case .warning: return DSColor.Warning.warning100
            case .error: return DSColor.Error.error100
            case .info: return DSColor.Info.info100
            case .neutral: return DSColor.Neutral.neutral80
            }
        }

        var backgroundColor: Color {
            switch self {
            case .success: return DSColor.Success.success20
            case .warning: return DSColor.Warning.warning20
            case .error: return DSColor.Error.error20
            case .info: return DSColor.Info.info20
            case .neutral: return DSColor.Neutral.neutral40
            }
        }

        var icon: Image {
            switch self {
            case .success: return DSIcons.Status.success
            case .warning: return DSIcons.Status.warning
            case .error: return DSIcons.Status.error
            case .info: return DSIcons.Status.info
            case .neutral: return DSIcons.Status.info
            }
        }
    }

    private let status: Status
    private let title: String
    private let message: String?
    private let action: (() -> Void)?
    private let actionTitle: String?

    public init(
        status: Status,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.status = status
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        DSCard(style: .filled, padding: .medium) {
            HStack(alignment: .top, spacing: DSSpacing.s) {
                status.icon
                    .font(.system(size: DSIconSize.m))
                    .foregroundColor(status.color)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(title)
                        .dsTextStyle(.labelMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)

                    if let message = message {
                        Text(message)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                    }

                    if let actionTitle = actionTitle, let action = action {
                        DSButton.link(actionTitle, size: .small, action: action)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Spacer()
            }
        }
        .background(status.backgroundColor)
        .dsCornerRadius(DSRadius.m)
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSCardPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Card Styles") {
                    VStack(spacing: DSSpacing.m) {
                        DSCard(style: .elevated) {
                            Text("Elevated Card")
                                .dsTextStyle(.bodyMedium)
                        }

                        DSCard(style: .outlined) {
                            Text("Outlined Card")
                                .dsTextStyle(.bodyMedium)
                        }

                        DSCard(style: .filled) {
                            Text("Filled Card")
                                .dsTextStyle(.bodyMedium)
                        }

                        DSCard(style: .transparent) {
                            Text("Transparent Card")
                                .dsTextStyle(.bodyMedium)
                        }
                    }
                }

                Section("Header Card") {
                    DSHeaderCard(
                        title: "Network Inspector",
                        subtitle: "Monitor API calls and responses",
                        trailing: { AnyView(DSIcons.Navigation.forward) }
                    ) {
                        Text("Card content goes here")
                            .dsTextStyle(.bodySmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                    }
                }

                Section("List Card") {
                    DSListCard(items: [
                        .init(
                            title: "GET /api/users",
                            subtitle: "200 • 150ms",
                            leadingIcon: DSIcons.Status.success,
                            trailing: AnyView(Text("1.2KB").dsTextStyle(.labelSmall)),
                            action: { }
                        ),
                        .init(
                            title: "POST /api/login",
                            subtitle: "401 • 2.1s",
                            leadingIcon: DSIcons.Status.error,
                            trailing: AnyView(Text("512B").dsTextStyle(.labelSmall)),
                            action: { }
                        ),
                        .init(
                            title: "GET /api/profile",
                            subtitle: "Loading...",
                            leadingIcon: DSIcons.Status.loading,
                            action: { }
                        )
                    ])
                }

                Section("Status Cards") {
                    VStack(spacing: DSSpacing.s) {
                        DSStatusCard(
                            status: .success,
                            title: "Connection Successful",
                            message: "All network requests are being monitored"
                        )

                        DSStatusCard(
                            status: .warning,
                            title: "Slow Network Detected",
                            message: "Some requests are taking longer than usual",
                            actionTitle: "View Details",
                            action: { }
                        )

                        DSStatusCard(
                            status: .error,
                            title: "Connection Failed",
                            message: "Unable to connect to the monitoring server",
                            actionTitle: "Retry",
                            action: { }
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DS Cards")
    }
}

@available(iOS 17.0, *)
#Preview("DS Cards") {
    DSCardPreview()
}
#endif
