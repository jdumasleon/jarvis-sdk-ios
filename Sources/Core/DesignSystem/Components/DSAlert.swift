import SwiftUI

// MARK: - Alert Component

public struct DSAlert: View {
    public enum Style {
        case info
        case success
        case warning
        case error

        var color: Color {
            switch self {
            case .info: return DSColor.Info.info100
            case .success: return DSColor.Success.success100
            case .warning: return DSColor.Warning.warning100
            case .error: return DSColor.Error.error100
            }
        }

        var backgroundColor: Color {
            switch self {
            case .info: return DSColor.Info.info20
            case .success: return DSColor.Success.success20
            case .warning: return DSColor.Warning.warning20
            case .error: return DSColor.Error.error20
            }
        }

        var icon: Image {
            switch self {
            case .info: return DSIcons.Status.info
            case .success: return DSIcons.Status.success
            case .warning: return DSIcons.Status.warning
            case .error: return DSIcons.Status.error
            }
        }
    }

    private let style: Style
    private let title: String
    private let message: String?
    private let primaryAction: (title: String, action: () -> Void)?
    private let secondaryAction: (title: String, action: () -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        style: Style,
        title: String,
        message: String? = nil,
        primaryAction: (title: String, action: () -> Void)? = nil,
        secondaryAction: (title: String, action: () -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Header
            HStack(alignment: .top, spacing: DSSpacing.s) {
                style.icon
                    .font(.system(size: DSIconSize.m))
                    .foregroundColor(style.color)

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(title)
                        .setTextStyle(.labelLarge)
                        .foregroundColor(DSColor.Text.primary)

                    if let message = message {
                        Text(message)
                            .setTextStyle(.bodySmall)
                            .foregroundColor(DSColor.Text.secondary)
                    }
                }

                Spacer()

                if let onDismiss = onDismiss {
                    DSIconButton(
                        icon: DSIcons.Navigation.close,
                        style: .ghost,
                        size: .small,
                        action: onDismiss
                    )
                }
            }

            // Actions
            if primaryAction != nil || secondaryAction != nil {
                HStack(spacing: DSSpacing.s) {
                    if let secondaryAction = secondaryAction {
                        DSButton.ghost(
                            secondaryAction.title,
                            size: .small,
                            action: secondaryAction.action
                        )
                    }

                    Spacer()

                    if let primaryAction = primaryAction {
                        DSButton(
                            primaryAction.title,
                            style: style == .error ? .destructive : .primary,
                            size: .small,
                            action: primaryAction.action
                        )
                    }
                }
            }
        }
        .dsPadding(DSSpacing.m)
        .background(style.backgroundColor)
        .dsCornerRadius(DSRadius.m)
        .dsBorder(style.color.opacity(0.2), width: DSBorderWidth.regular)
    }
}

// MARK: - Banner Alert

public struct DSBanner: View {
    private let style: DSAlert.Style
    private let title: String
    private let message: String?
    private let action: (title: String, action: () -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        style: DSAlert.Style,
        title: String,
        message: String? = nil,
        action: (title: String, action: () -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            style.icon
                .font(.system(size: DSIconSize.s))
                .foregroundColor(style.color)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .setTextStyle(.labelSmall)
                    .foregroundColor(DSColor.Text.primary)

                if let message = message {
                    Text(message)
                        .setTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Text.secondary)
                }
            }

            Spacer()

            if let action = action {
                DSButton.link(action.title, size: .small, action: action.action)
            }

            if let onDismiss = onDismiss {
                DSIconButton(
                    icon: DSIcons.Navigation.close,
                    style: .ghost,
                    size: .small,
                    action: onDismiss
                )
            }
        }
        .dsPadding(.horizontal, DSSpacing.m)
        .dsPadding(.vertical, DSSpacing.s)
        .background(style.backgroundColor)
        .dsBorder(style.color.opacity(0.3), width: DSBorderWidth.regular)
    }
}

// MARK: - Modal Sheet

public struct DSModal<Content: View>: View {
    @Binding private var isPresented: Bool
    private let title: String?
    private let primaryAction: (title: String, action: () -> Void)?
    private let secondaryAction: (title: String, action: () -> Void)?
    private let onDismiss: (() -> Void)?
    private let content: Content

    public init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        primaryAction: (title: String, action: () -> Void)? = nil,
        secondaryAction: (title: String, action: () -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.onDismiss = onDismiss
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            // Header
            if title != nil || onDismiss != nil {
                HStack {
                    if let title = title {
                        Text(title)
                            .setTextStyle(.titleMedium)
                            .foregroundColor(DSColor.Text.primary)
                    }

                    Spacer()

                    if let onDismiss = onDismiss {
                        DSIconButton(
                            icon: DSIcons.Navigation.close,
                            style: .ghost,
                            size: .medium,
                            action: {
                                isPresented = false
                                onDismiss()
                            }
                        )
                    }
                }
                .dsPadding(DSSpacing.m)
                .background(DSColor.Surface.surface)

                Divider()
                    .background(DSColor.Surface.divider)
            }

            // Content
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Actions
            if primaryAction != nil || secondaryAction != nil {
                Divider()
                    .background(DSColor.Surface.divider)

                HStack(spacing: DSSpacing.s) {
                    if let secondaryAction = secondaryAction {
                        DSButton.outline(
                            secondaryAction.title,
                            action: {
                                secondaryAction.action()
                                isPresented = false
                            }
                        )
                    }

                    if let primaryAction = primaryAction {
                        DSButton.primary(
                            primaryAction.title,
                            action: {
                                primaryAction.action()
                                isPresented = false
                            }
                        )
                    }
                }
                .dsPadding(DSSpacing.m)
                .background(DSColor.Surface.surface)
            }
        }
        .background(DSColor.Surface.surface)
        .dsCornerRadius(DSRadius.l)
        .dsShadowLarge()
    }
}

// MARK: - Confirmation Dialog

public struct DSConfirmationDialog: View {
    @Binding private var isPresented: Bool
    private let title: String
    private let message: String?
    private let destructiveAction: (title: String, action: () -> Void)?
    private let cancelAction: (title: String, action: () -> Void)?

    public init(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        destructiveAction: (title: String, action: () -> Void)? = nil,
        cancelAction: (title: String, action: () -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.destructiveAction = destructiveAction
        self.cancelAction = cancelAction
    }

    public var body: some View {
        VStack(spacing: DSSpacing.l) {
            VStack(spacing: DSSpacing.s) {
                Text(title)
                    .setTextStyle(.titleMedium)
                    .foregroundColor(DSColor.Text.primary)
                    .multilineTextAlignment(.center)

                if let message = message {
                    Text(message)
                        .setTextStyle(.bodyMedium)
                        .foregroundColor(DSColor.Text.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: DSSpacing.s) {
                if let destructiveAction = destructiveAction {
                    DSButton.destructive(
                        destructiveAction.title,
                        action: {
                            destructiveAction.action()
                            isPresented = false
                        }
                    )
                }

                if let cancelAction = cancelAction {
                    DSButton.outline(
                        cancelAction.title,
                        action: {
                            cancelAction.action()
                            isPresented = false
                        }
                    )
                } else {
                    DSButton.outline("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .dsPadding(DSSpacing.xl)
        .background(DSColor.Surface.surface)
        .dsCornerRadius(DSRadius.l)
        .dsShadowLarge()
        .frame(maxWidth: 320)
    }
}

// MARK: - Toast Notification

public struct DSToast: View {
    public enum Style {
        case info
        case success
        case warning
        case error

        var color: Color {
            switch self {
            case .info: return DSColor.Info.info100
            case .success: return DSColor.Success.success100
            case .warning: return DSColor.Warning.warning100
            case .error: return DSColor.Error.error100
            }
        }

        var icon: Image {
            switch self {
            case .info: return DSIcons.Status.info
            case .success: return DSIcons.Status.success
            case .warning: return DSIcons.Status.warning
            case .error: return DSIcons.Status.error
            }
        }
    }

    private let style: Style
    private let title: String
    private let message: String?
    private let onDismiss: (() -> Void)?

    public init(
        style: Style,
        title: String,
        message: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            style.icon
                .font(.system(size: DSIconSize.m))
                .foregroundColor(style.color)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .setTextStyle(.labelMedium)
                    .foregroundColor(DSColor.Text.primary)

                if let message = message {
                    Text(message)
                        .setTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Text.secondary)
                }
            }

            Spacer()

            if let onDismiss = onDismiss {
                DSIconButton(
                    icon: DSIcons.Navigation.close,
                    style: .ghost,
                    size: .small,
                    action: onDismiss
                )
            }
        }
        .dsPadding(DSSpacing.m)
        .background(DSColor.Surface.surface)
        .dsCornerRadius(DSRadius.m)
        .dsShadowMedium()
        .dsBorder(DSColor.Surface.border)
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSAlertPreview: View {
    @State private var showModal = false
    @State private var showConfirmation = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Alerts") {
                    VStack(spacing: DSSpacing.m) {
                        DSAlert(
                            style: .info,
                            title: "Information",
                            message: "This is an informational message",
                            primaryAction: ("Got it", { }),
                            onDismiss: { }
                        )

                        DSAlert(
                            style: .success,
                            title: "Success",
                            message: "Operation completed successfully",
                            primaryAction: ("Continue", { })
                        )

                        DSAlert(
                            style: .warning,
                            title: "Warning",
                            message: "Please review your settings",
                            primaryAction: ("Review", { }),
                            secondaryAction: ("Later", { })
                        )

                        DSAlert(
                            style: .error,
                            title: "Error",
                            message: "Something went wrong",
                            primaryAction: ("Retry", { }),
                            secondaryAction: ("Cancel", { })
                        )
                    }
                }

                Section("Banners") {
                    VStack(spacing: DSSpacing.s) {
                        DSBanner(
                            style: .info,
                            title: "New feature available",
                            action: ("Learn more", { })
                        )

                        DSBanner(
                            style: .warning,
                            title: "Update required",
                            message: "Please update to continue",
                            onDismiss: { }
                        )
                    }
                }

                Section("Toasts") {
                    VStack(spacing: DSSpacing.s) {
                        DSToast(
                            style: .success,
                            title: "Settings saved",
                            onDismiss: { }
                        )

                        DSToast(
                            style: .error,
                            title: "Network error",
                            message: "Failed to connect to server"
                        )
                    }
                }

                Section("Modal Dialogs") {
                    VStack(spacing: DSSpacing.s) {
                        DSButton.primary("Show Modal") {
                            showModal = true
                        }

                        DSButton.destructive("Show Confirmation") {
                            showConfirmation = true
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showModal) {
            DSModal(
                isPresented: $showModal,
                title: "Modal Example",
                primaryAction: ("Save", { }),
                secondaryAction: ("Cancel", { })
            ) {
                VStack(spacing: DSSpacing.m) {
                    Text("This is modal content")
                        .setTextStyle(.bodyMedium)
                        .dsPadding(DSSpacing.xl)

                    Spacer()
                }
            }
        }
        .overlay(
            Group {
                if showConfirmation {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showConfirmation = false
                        }

                    DSConfirmationDialog(
                        isPresented: $showConfirmation,
                        title: "Delete Item",
                        message: "Are you sure you want to delete this item? This action cannot be undone.",
                        destructiveAction: ("Delete", { }),
                        cancelAction: ("Cancel", { })
                    )
                }
            }
        )
        .navigationTitle("Alerts & Modals")
    }
}

@available(iOS 17.0, *)
#Preview("Alerts & Modals") {
    DSAlertPreview()
}
#endif
