import SwiftUI

// MARK: - Navigation Bar

public struct DSNavigationBar: View {
    private let title: String?
    private let leftItems: [DSNavigationItem]
    private let rightItems: [DSNavigationItem]
    private let style: Style

    public enum Style {
        case standard
        case large
        case transparent

        var backgroundColor: Color {
            switch self {
            case .standard, .large:
                return DSColor.Extra.white
            case .transparent:
                return Color.clear
            }
        }

        var titleStyle: DSTextStyle {
            switch self {
            case .standard, .transparent:
                return .titleMedium
            case .large:
                return .headlineSmall
            }
        }
    }

    public struct DSNavigationItem {
        public let icon: Image?
        public let title: String?
        public let action: () -> Void

        public init(icon: Image, action: @escaping () -> Void) {
            self.icon = icon
            self.title = nil
            self.action = action
        }

        public init(title: String, action: @escaping () -> Void) {
            self.icon = nil
            self.title = title
            self.action = action
        }
    }

    public init(
        title: String? = nil,
        leftItems: [DSNavigationItem] = [],
        rightItems: [DSNavigationItem] = [],
        style: Style = .standard
    ) {
        self.title = title
        self.leftItems = leftItems
        self.rightItems = rightItems
        self.style = style
    }

    public var body: some View {
        HStack {
            // Left items
            HStack(spacing: DSSpacing.xs) {
                ForEach(Array(leftItems.enumerated()), id: \.offset) { _, item in
                    if let icon = item.icon {
                        DSIconButton(
                            icon: icon,
                            style: .ghost,
                            size: .medium,
                            action: item.action
                        )
                    } else if let title = item.title {
                        DSButton.link(title, size: .medium, action: item.action)
                    }
                }
            }

            Spacer()

            // Title
            if let title = title {
                Text(title)
                    .dsTextStyle(style.titleStyle)
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Right items
            HStack(spacing: DSSpacing.xs) {
                ForEach(Array(rightItems.enumerated()), id: \.offset) { _, item in
                    if let icon = item.icon {
                        DSIconButton(
                            icon: icon,
                            style: .ghost,
                            size: .medium,
                            action: item.action
                        )
                    } else if let title = item.title {
                        DSButton.link(title, size: .medium, action: item.action)
                    }
                }
            }
        }
        .frame(height: DSLayoutValues.toolbarHeight)
        .dsPadding(.horizontal, DSSpacing.m)
        .background(style.backgroundColor)
        .overlay(
            Rectangle()
                .frame(height: DSBorderWidth.thin)
                .foregroundColor(DSColor.Neutral.neutral20),
            alignment: .bottom
        )
    }
}

// MARK: - Tab Bar

public struct DSTabBar: View {
    @Binding private var selectedTab: String
    private let tabs: [DSTab]

    public struct DSTab: Identifiable {
        public let id: String
        public let title: String
        public let icon: Image
        public let selectedIcon: Image?
        public let badge: String?

        public init(
            id: String,
            title: String,
            icon: Image,
            selectedIcon: Image? = nil,
            badge: String? = nil
        ) {
            self.id = id
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
            self.badge = badge
        }
    }

    public init(
        selectedTab: Binding<String>,
        tabs: [DSTab]
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs
    }

    public var body: some View {
        HStack(spacing: DSSpacing.none) {
            ForEach(tabs) { tab in
                DSTabItem(
                    tab: tab,
                    isSelected: selectedTab == tab.id,
                    action: {
                        selectedTab = tab.id
                    }
                )
            }
        }
        .frame(height: DSLayoutValues.tabBarHeight)
        .background(DSColor.Extra.white)
        .overlay(
            Rectangle()
                .frame(height: DSBorderWidth.thin)
                .foregroundColor(DSColor.Neutral.neutral20),
            alignment: .top
        )
    }
}

// MARK: - Tab Item

private struct DSTabItem: View {
    let tab: DSTabBar.DSTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xxs) {
                ZStack {
                    Group {
                        if isSelected {
                            tab.selectedIcon ?? tab.icon
                        } else {
                            tab.icon
                        }
                    }
                    .font(.system(size: DSIconSize.m))
                    .foregroundColor(isSelected ? DSColor.Primary.primary100 : DSColor.Neutral.neutral60)

                    // Badge
                    if let badge = tab.badge {
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

                Text(tab.title)
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(isSelected ? DSColor.Primary.primary100 : DSColor.Neutral.neutral60)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Breadcrumb

public struct DSBreadcrumb: View {
    public struct Item: Identifiable {
        public let id = UUID()
        public let title: String
        public let action: (() -> Void)?

        public init(title: String, action: (() -> Void)? = nil) {
            self.title = title
            self.action = action
        }
    }

    private let items: [Item]

    public init(items: [Item]) {
        self.items = items
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if let action = item.action {
                    Button(action: action) {
                        Text(item.title)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Primary.primary60)
                    }
                } else {
                    Text(item.title)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral100)
                }

                if index < items.count - 1 {
                    DSIcons.Navigation.forward
                        .font(.system(size: DSIconSize.xs))
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
            }

            Spacer()
        }
        .dsPadding(.horizontal, DSSpacing.m)
        .dsPadding(.vertical, DSSpacing.s)
    }
}

// MARK: - Segmented Control

public struct DSSegmentedControl: View {
    @Binding private var selectedSegment: String
    private let segments: [Segment]

    public struct Segment: Identifiable {
        public let id: String
        public let title: String
        public let icon: Image?

        public init(id: String, title: String, icon: Image? = nil) {
            self.id = id
            self.title = title
            self.icon = icon
        }
    }

    public init(
        selectedSegment: Binding<String>,
        segments: [Segment]
    ) {
        self._selectedSegment = selectedSegment
        self.segments = segments
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            ForEach(segments) { segment in
                Button(action: {
                    selectedSegment = segment.id
                }) {
                    HStack(spacing: DSSpacing.xs) {
                        if let icon = segment.icon {
                            icon
                                .font(.system(size: DSIconSize.s))
                                .foregroundColor(foregroundColor(for: segment))
                        }

                        Text(segment.title)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(foregroundColor(for: segment))
                    }
                    .dsPadding(.horizontal, DSSpacing.s)
                    .dsPadding(.vertical, DSSpacing.xs)
                    .background(backgroundColor(for: segment))
                    .dsCornerRadius(DSRadius.s)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .dsPadding(DSSpacing.xxs)
        .background(DSColor.Neutral.neutral0)
        .dsCornerRadius(DSRadius.s)
    }

    private func backgroundColor(for segment: Segment) -> Color {
        selectedSegment == segment.id ? DSColor.Extra.white : Color.clear
    }

    private func foregroundColor(for segment: Segment) -> Color {
        selectedSegment == segment.id ? DSColor.Neutral.neutral100 : DSColor.Neutral.neutral80
    }
}

// MARK: - Pagination

public struct DSPagination: View {
    @Binding private var currentPage: Int
    private let totalPages: Int
    private let visiblePages: Int

    public init(
        currentPage: Binding<Int>,
        totalPages: Int,
        visiblePages: Int = 5
    ) {
        self._currentPage = currentPage
        self.totalPages = totalPages
        self.visiblePages = visiblePages
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            // Previous button
            DSIconButton(
                icon: DSIcons.Navigation.back,
                style: .ghost,
                size: .small,
                isEnabled: currentPage > 1,
                action: {
                    if currentPage > 1 {
                        currentPage -= 1
                    }
                }
            )

            // Page numbers
            ForEach(visiblePageRange, id: \.self) { page in
                if page == -1 {
                    Text("...")
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .frame(width: 32, height: 32)
                } else {
                    Button(action: {
                        currentPage = page
                    }) {
                        Text("\(page)")
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(currentPage == page ? DSColor.Extra.white : DSColor.Neutral.neutral100)
                            .frame(width: 32, height: 32)
                            .background(currentPage == page ? DSColor.Primary.primary100 : Color.clear)
                            .dsCornerRadius(DSRadius.s)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            // Next button
            DSIconButton(
                icon: DSIcons.Navigation.forward,
                style: .ghost,
                size: .small,
                isEnabled: currentPage < totalPages,
                action: {
                    if currentPage < totalPages {
                        currentPage += 1
                    }
                }
            )
        }
    }

    private var visiblePageRange: [Int] {
        let halfVisible = visiblePages / 2
        var start = max(1, currentPage - halfVisible)
        var end = min(totalPages, start + visiblePages - 1)

        if end - start + 1 < visiblePages {
            start = max(1, end - visiblePages + 1)
        }

        var pages: [Int] = []

        // Add first page if not in range
        if start > 1 {
            pages.append(1)
            if start > 2 {
                pages.append(-1) // Ellipsis
            }
        }

        // Add visible range
        for page in start...end {
            pages.append(page)
        }

        // Add last page if not in range
        if end < totalPages {
            if end < totalPages - 1 {
                pages.append(-1) // Ellipsis
            }
            pages.append(totalPages)
        }

        return pages
    }
}

// MARK: - Step Indicator

public struct DSStepIndicator: View {
    private let steps: [Step]
    private let currentStep: Int

    public struct Step {
        public let title: String
        public let isCompleted: Bool

        public init(title: String, isCompleted: Bool = false) {
            self.title = title
            self.isCompleted = isCompleted
        }
    }

    public init(steps: [Step], currentStep: Int) {
        self.steps = steps
        self.currentStep = currentStep
    }

    public var body: some View {
        HStack(spacing: DSSpacing.none) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                VStack(spacing: DSSpacing.xs) {
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(circleBackgroundColor(for: index))
                            .frame(width: 32, height: 32)

                        if step.isCompleted {
                            DSIcons.Status.success
                                .font(.system(size: DSIconSize.s))
                                .foregroundColor(DSColor.Extra.white)
                        } else {
                            Text("\(index + 1)")
                                .dsTextStyle(.labelSmall)
                                .foregroundColor(circleTextColor(for: index))
                        }
                    }

                    // Step title
                    Text(step.title)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(titleColor(for: index))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                // Connector line
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(lineColor(for: index))
                        .frame(height: DSBorderWidth.regular)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func circleBackgroundColor(for index: Int) -> Color {
        if steps[index].isCompleted {
            return DSColor.Success.success100
        } else if index == currentStep {
            return DSColor.Primary.primary100
        } else {
            return DSColor.Neutral.neutral60
        }
    }

    private func circleTextColor(for index: Int) -> Color {
        if index == currentStep {
            return DSColor.Extra.white
        } else {
            return DSColor.Neutral.neutral80
        }
    }

    private func titleColor(for index: Int) -> Color {
        if steps[index].isCompleted || index == currentStep {
            return DSColor.Neutral.neutral100
        } else {
            return DSColor.Neutral.neutral80
        }
    }

    private func lineColor(for index: Int) -> Color {
        if steps[index].isCompleted {
            return DSColor.Success.success100
        } else {
            return DSColor.Neutral.neutral60
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSNavigationPreview: View {
    @State private var selectedTab = "home"
    @State private var selectedSegment = "all"
    @State private var currentPage = 3

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Navigation Bar") {
                    VStack(spacing: DSSpacing.m) {
                        DSNavigationBar(
                            title: "Network Inspector",
                            leftItems: [
                                .init(icon: DSIcons.Navigation.back) { }
                            ],
                            rightItems: [
                                .init(icon: DSIcons.Action.share) { },
                                .init(icon: DSIcons.Navigation.more) { }
                            ]
                        )

                        DSNavigationBar(
                            title: "Large Title",
                            rightItems: [
                                .init(title: "Done") { }
                            ],
                            style: .large
                        )
                    }
                }

                Section("Tab Bar") {
                    DSTabBar(
                        selectedTab: $selectedTab,
                        tabs: [
                            .init(id: "home", title: "Home", icon: DSIcons.Navigation.home, selectedIcon: DSIcons.Navigation.homeFilled),
                            .init(id: "inspector", title: "Inspector", icon: DSIcons.Jarvis.inspector, badge: "3"),
                            .init(id: "preferences", title: "Preferences", icon: DSIcons.Jarvis.preferences),
                            .init(id: "settings", title: "Settings", icon: DSIcons.System.settings)
                        ]
                    )
                }

                Section("Breadcrumb") {
                    DSBreadcrumb(items: [
                        .init(title: "Home") { },
                        .init(title: "Network") { },
                        .init(title: "Request Details")
                    ])
                }

                Section("Segmented Control") {
                    DSSegmentedControl(
                        selectedSegment: $selectedSegment,
                        segments: [
                            .init(id: "all", title: "All"),
                            .init(id: "success", title: "Success", icon: DSIcons.Status.success),
                            .init(id: "error", title: "Error", icon: DSIcons.Status.error)
                        ]
                    )
                }

                Section("Pagination") {
                    DSPagination(
                        currentPage: $currentPage,
                        totalPages: 10
                    )
                }

                Section("Step Indicator") {
                    DSStepIndicator(
                        steps: [
                            .init(title: "Setup", isCompleted: true),
                            .init(title: "Configure", isCompleted: true),
                            .init(title: "Monitor"),
                            .init(title: "Analyze")
                        ],
                        currentStep: 2
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Navigation")
    }
}

@available(iOS 17.0, *)
#Preview("Navigation") {
    DSNavigationPreview()
}
#endif
