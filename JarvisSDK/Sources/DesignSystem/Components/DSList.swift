import SwiftUI

// MARK: - List Section Header

public struct DSSectionHeader: View {
    private let title: String
    private let subtitle: String?
    private let trailing: AnyView?

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> AnyView = { AnyView(EmptyView()) }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .dsTextStyle(.labelLarge)
                    .foregroundColor(DSColor.Neutral.neutral100)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                }
            }

            Spacer()

            trailing
        }
        .dsPadding(.horizontal, DSSpacing.m)
        .dsPadding(.vertical, DSSpacing.s)
        .background(DSColor.Neutral.neutral0)
    }
}

// MARK: - List Row

public struct DSListRow: View {
    public struct Configuration {
        public let title: String
        public let subtitle: String?
        public let description: String?
        public let leadingIcon: Image?
        public let leadingView: AnyView?
        public let trailingIcon: Image?
        public let trailingView: AnyView?
        public let badge: String?
        public let isSelected: Bool
        public let isDisabled: Bool
        public let action: (() -> Void)?

        public init(
            title: String,
            subtitle: String? = nil,
            description: String? = nil,
            leadingIcon: Image? = nil,
            leadingView: AnyView? = nil,
            trailingIcon: Image? = nil,
            trailingView: AnyView? = nil,
            badge: String? = nil,
            isSelected: Bool = false,
            isDisabled: Bool = false,
            action: (() -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.leadingIcon = leadingIcon
            self.leadingView = leadingView
            self.trailingIcon = trailingIcon
            self.trailingView = trailingView
            self.badge = badge
            self.isSelected = isSelected
            self.isDisabled = isDisabled
            self.action = action
        }
    }

    private let config: Configuration

    public init(_ config: Configuration) {
        self.config = config
    }

    public var body: some View {
        Button(action: config.action ?? {}) {
            HStack(spacing: DSSpacing.s) {
                // Leading content
                leadingContent

                // Main content
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    HStack {
                        Text(config.title)
                            .dsTextStyle(.bodyMedium)
                            .foregroundColor(titleColor)

                        if let badge = config.badge {
                            DSBadge(text: badge, style: .secondary)
                        }

                        Spacer()
                    }

                    if let subtitle = config.subtitle {
                        Text(subtitle)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(subtitleColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let description = config.description {
                        Text(description)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral60)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Trailing content
                trailingContent
            }
            .dsPadding(.horizontal, DSSpacing.m)
            .dsPadding(.vertical, DSSpacing.s)
            .background(backgroundColor)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(config.isDisabled || config.action == nil)
    }

    @ViewBuilder
    private var leadingContent: some View {
        if let leadingView = config.leadingView {
            leadingView
        } else if let leadingIcon = config.leadingIcon {
            leadingIcon
                .font(.system(size: DSIconSize.m))
                .foregroundColor(iconColor)
                .frame(width: DSIconSize.l, height: DSIconSize.l)
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        if let trailingView = config.trailingView {
            trailingView
        } else if let trailingIcon = config.trailingIcon {
            trailingIcon
                .font(.system(size: DSIconSize.s))
                .foregroundColor(iconColor)
        } else if config.action != nil {
            DSIcons.Navigation.forward
                .font(.system(size: DSIconSize.s))
                .foregroundColor(DSColor.Neutral.neutral60)
        }
    }

    private var backgroundColor: Color {
        if config.isSelected {
            return DSColor.Primary.primary20
        } else {
            return Color.clear
        }
    }

    private var titleColor: Color {
        if config.isDisabled {
            return DSColor.Neutral.neutral40
        } else if config.isSelected {
            return DSColor.Primary.primary60
        } else {
            return DSColor.Neutral.neutral100
        }
    }

    private var subtitleColor: Color {
        if config.isDisabled {
            return DSColor.Neutral.neutral40
        } else {
            return DSColor.Neutral.neutral80
        }
    }

    private var iconColor: Color {
        if config.isDisabled {
            return DSColor.Neutral.neutral40
        } else if config.isSelected {
            return DSColor.Primary.primary80
        } else {
            return DSColor.Neutral.neutral80
        }
    }
}

// MARK: - Badge Component

public struct DSBadge: View {
    public enum Style {
        case primary
        case secondary
        case success
        case warning
        case error
        case info

        var backgroundColor: Color {
            switch self {
            case .primary: return DSColor.Primary.primary100
            case .secondary: return DSColor.Secondary.secondary100
            case .success: return DSColor.Success.success100
            case .warning: return DSColor.Warning.warning100
            case .error: return DSColor.Error.error100
            case .info: return DSColor.Info.info100
            }
        }

        var textColor: Color {
            switch self {
            case .primary, .secondary, .success, .warning, .error, .info:
                return DSColor.Extra.white
            }
        }
    }

    private let text: String
    private let style: Style

    public init(text: String, style: Style = .primary) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .dsTextStyle(.labelSmall)
            .foregroundColor(style.textColor)
            .dsPadding(.horizontal, DSSpacing.xs)
            .dsPadding(.vertical, DSSpacing.xxs)
            .background(style.backgroundColor)
            .dsCornerRadius(DSRadius.xs)
    }
}

// MARK: - Data Table

public struct DSDataTable<RowData: Identifiable>: View {
    public struct Column {
        public let title: String
        public let width: CGFloat?
        public let alignment: Alignment
        public let content: (RowData) -> AnyView

        public init(
            title: String,
            width: CGFloat? = nil,
            alignment: Alignment = .leading,
            @ViewBuilder content: @escaping (RowData) -> AnyView
        ) {
            self.title = title
            self.width = width
            self.alignment = alignment
            self.content = content
        }
    }

    private let data: [RowData]
    private let columns: [Column]
    private let isSelectable: Bool
    private let selectedRows: Set<RowData.ID>
    private let onRowSelection: ((RowData.ID) -> Void)?

    public init(
        data: [RowData],
        columns: [Column],
        isSelectable: Bool = false,
        selectedRows: Set<RowData.ID> = [],
        onRowSelection: ((RowData.ID) -> Void)? = nil
    ) {
        self.data = data
        self.columns = columns
        self.isSelectable = isSelectable
        self.selectedRows = selectedRows
        self.onRowSelection = onRowSelection
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            // Header
            HStack(spacing: DSSpacing.s) {
                if isSelectable {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 24, height: 24)
                }

                ForEach(Array(columns.enumerated()), id: \.offset) { index, column in
                    Text(column.title)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                        .frame(
                            maxWidth: column.width ?? .infinity,
                            alignment: column.alignment == .leading ? .leading :
                                      column.alignment == .trailing ? .trailing : .center
                        )

                    if index < columns.count - 1 {
                        Spacer()
                    }
                }
            }
            .dsPadding(.horizontal, DSSpacing.m)
            .dsPadding(.vertical, DSSpacing.s)
            .background(DSColor.Neutral.neutral0)

            Divider()
                .background(DSColor.Neutral.neutral20)

            // Rows
            LazyVStack(spacing: DSSpacing.none) {
                ForEach(data) { row in
                    HStack(spacing: DSSpacing.s) {
                        if isSelectable {
                            Button(action: {
                                onRowSelection?(row.id)
                            }) {
                                Image(systemName: selectedRows.contains(row.id) ? "checkmark.square.fill" : "square")
                                    .font(.system(size: DSIconSize.m))
                                    .foregroundColor(selectedRows.contains(row.id) ? DSColor.Primary.primary100 : DSColor.Neutral.neutral60)
                            }
                        }

                        ForEach(Array(columns.enumerated()), id: \.offset) { index, column in
                            column.content(row)
                                .frame(
                                    maxWidth: column.width ?? .infinity,
                                    alignment: column.alignment == .leading ? .leading :
                                              column.alignment == .trailing ? .trailing : .center
                                )

                            if index < columns.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .dsPadding(.horizontal, DSSpacing.m)
                    .dsPadding(.vertical, DSSpacing.s)
                    .background(
                        selectedRows.contains(row.id) ? DSColor.Primary.primary20 : Color.clear
                    )

                    if row.id != data.last?.id {
                        Divider()
                            .background(DSColor.Neutral.neutral20)
                            .dsPadding(.horizontal, DSSpacing.m)
                    }
                }
            }
        }
        .background(DSColor.Extra.white)
        .dsCornerRadius(DSRadius.m)
        .dsBorder(DSColor.Neutral.neutral20)
    }
}

// MARK: - Empty State

public struct DSEmptyState: View {
    private let icon: Image
    private let title: String
    private let description: String?
    private let primaryAction: (title: String, action: () -> Void)?
    private let secondaryAction: (title: String, action: () -> Void)?

    public init(
        icon: Image,
        title: String,
        description: String? = nil,
        primaryAction: (title: String, action: () -> Void)? = nil,
        secondaryAction: (title: String, action: () -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        VStack(spacing: DSSpacing.l) {
            VStack(spacing: DSSpacing.m) {
                icon
                    .font(.system(size: DSIconSize.xxxl))
                    .foregroundColor(DSColor.Neutral.neutral60)

                VStack(spacing: DSSpacing.s) {
                    Text(title)
                        .dsTextStyle(.titleMedium)
                        .foregroundColor(DSColor.Neutral.neutral100)
                        .multilineTextAlignment(.center)

                    if let description = description {
                        Text(description)
                            .dsTextStyle(.bodyMedium)
                            .foregroundColor(DSColor.Neutral.neutral80)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            if primaryAction != nil || secondaryAction != nil {
                VStack(spacing: DSSpacing.s) {
                    if let primaryAction = primaryAction {
                        DSButton.primary(primaryAction.title, action: primaryAction.action)
                    }

                    if let secondaryAction = secondaryAction {
                        DSButton.ghost(secondaryAction.title, action: secondaryAction.action)
                    }
                }
                .frame(maxWidth: 200)
            }
        }
        .dsPadding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State

public struct DSLoadingState: View {
    private let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.m) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DSColor.Primary.primary100))
                .scaleEffect(1.2)

            if let message = message {
                Text(message)
                    .dsTextStyle(.bodyMedium)
                    .foregroundColor(DSColor.Neutral.neutral80)
                    .multilineTextAlignment(.center)
            }
        }
        .dsPadding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSListPreview: View {
    @State private var selectedRows: Set<String> = []

    public init() {}

    private struct SampleData: Identifiable {
        let id = UUID().uuidString
        let method: String
        let url: String
        let status: Int
        let duration: String
        let size: String
    }

    private let sampleData = [
        SampleData(method: "GET", url: "/api/users", status: 200, duration: "120ms", size: "1.2KB"),
        SampleData(method: "POST", url: "/api/login", status: 401, duration: "2.1s", size: "512B"),
        SampleData(method: "GET", url: "/api/profile", status: 200, duration: "89ms", size: "856B"),
        SampleData(method: "DELETE", url: "/api/users/123", status: 204, duration: "45ms", size: "0B")
    ]

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Section Header") {
                    DSSectionHeader(
                        title: "Network Requests",
                        subtitle: "Last 24 hours",
                        trailing: {
                            AnyView(
                                DSButton.ghost("Clear", size: .small) { }
                            )
                        }
                    )
                }

                Section("List Rows") {
                    VStack(spacing: DSSpacing.none) {
                        DSListRow(.init(
                            title: "GET /api/users",
                            subtitle: "200 • 120ms",
                            leadingIcon: DSIcons.Status.success,
                            trailingView: AnyView(Text("1.2KB").dsTextStyle(.labelSmall)),
                            action: { }
                        ))

                        Divider().background(DSColor.Neutral.neutral20)

                        DSListRow(.init(
                            title: "POST /api/login",
                            subtitle: "401 • 2.1s",
                            description: "Authentication failed",
                            leadingIcon: DSIcons.Status.error,
                            badge: "ERROR",
                            action: { }
                        ))

                        Divider().background(DSColor.Neutral.neutral20)

                        DSListRow(.init(
                            title: "Loading request...",
                            leadingView: AnyView(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: DSColor.Primary.primary100))
                                    .scaleEffect(0.8)
                            )
                        ))
                    }
                    .background(DSColor.Extra.white)
                    .dsCornerRadius(DSRadius.m)
                    .dsBorder(DSColor.Neutral.neutral20)
                }

                Section("Badges") {
                    HStack(spacing: DSSpacing.s) {
                        DSBadge(text: "NEW", style: .primary)
                        DSBadge(text: "SUCCESS", style: .success)
                        DSBadge(text: "WARNING", style: .warning)
                        DSBadge(text: "ERROR", style: .error)
                        DSBadge(text: "INFO", style: .info)
                    }
                }

                Section("Data Table") {
                    DSDataTable(
                        data: sampleData,
                        columns: [
                            .init(title: "Method", width: 60) { data in
                                AnyView(
                                    Text(data.method)
                                        .dsTextStyle(.labelSmall)
                                        .foregroundColor(
                                            data.method == "GET" ? DSColor.Success.success80 :
                                            data.method == "POST" ? DSColor.Info.info80 :
                                            data.method == "DELETE" ? DSColor.Error.error80 :
                                            DSColor.Neutral.neutral100
                                        )
                                )
                            },
                            .init(title: "URL") { data in
                                AnyView(
                                    Text(data.url)
                                        .dsTextStyle(.bodySmall)
                                        .foregroundColor(DSColor.Neutral.neutral100)
                                )
                            },
                            .init(title: "Status", width: 60, alignment: .center) { data in
                                AnyView(
                                    Text("\(data.status)")
                                        .dsTextStyle(.labelSmall)
                                        .foregroundColor(
                                            data.status >= 200 && data.status < 300 ? DSColor.Success.success80 :
                                            data.status >= 400 ? DSColor.Error.error80 :
                                            DSColor.Neutral.neutral100
                                        )
                                )
                            },
                            .init(title: "Size", width: 60, alignment: .trailing) { data in
                                AnyView(
                                    Text(data.size)
                                        .dsTextStyle(.labelSmall)
                                        .foregroundColor(DSColor.Neutral.neutral80)
                                )
                            }
                        ],
                        isSelectable: true,
                        selectedRows: selectedRows,
                        onRowSelection: { id in
                            if selectedRows.contains(id) {
                                selectedRows.remove(id)
                            } else {
                                selectedRows.insert(id)
                            }
                        }
                    )
                }

                Section("Empty State") {
                    DSEmptyState(
                        icon: DSIcons.Jarvis.inspector,
                        title: "No Requests Found",
                        description: "Start using your app to see network requests appear here.",
                        primaryAction: ("Refresh", { }),
                        secondaryAction: ("Learn More", { })
                    )
                    .frame(height: 200)
                }

                Section("Loading State") {
                    DSLoadingState(message: "Loading network requests...")
                        .frame(height: 150)
                }
            }
            .padding()
        }
        .navigationTitle("Lists & Data")
    }
}

@available(iOS 17.0, *)
#Preview("Lists & Data") {
    DSListPreview()
}
#endif
