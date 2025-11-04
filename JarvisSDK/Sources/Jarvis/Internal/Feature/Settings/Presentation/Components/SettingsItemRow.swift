//
//  SettingsItemRow.swift
//  JarvisSDK
//
//  Reusable row component for settings items
//

import SwiftUI
import DesignSystem

/// Reusable row component for displaying a settings item
struct SettingsItemRow: View {
    let item: SettingsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.m) {
                // Icon
                iconView
                    .frame(width: DSDimensions.xl, height: DSDimensions.xl)

                // Content
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    DSText(
                        item.title,
                        style: .bodyMedium,
                        color: item.isEnabled ? DSColor.Extra.onSurface : DSColor.Neutral.neutral60
                    )

                    if let description = item.description {
                        DSText(
                            description,
                            style: .bodySmall,
                            color: DSColor.Neutral.neutral80
                        )
                    }
                }

                Spacer()

                // Trailing content
                trailingView
            }
            .padding(.vertical, DSSpacing.xs)
            .padding(.horizontal, DSSpacing.m)
        }
        .disabled(!item.isEnabled)
        .opacity(item.isEnabled ? 1.0 : 0.5)
    }

    // MARK: - Icon View

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            iconImage
                .font(.system(size: DSIconSize.m))
                .foregroundStyle(
                    item.isEnabled
                        ? iconGradient
                        : LinearGradient(
                            colors: [DSColor.Neutral.neutral60, DSColor.Neutral.neutral60],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
        }
    }

    private var iconImage: Image {
        switch item.icon {
        case .star:
            return DSIcons.Action.starCircleFilled
        case .share:
            return DSIcons.Action.share
        case .info:
            return DSIcons.Status.info
        case .link:
            return DSIcons.File.link
        case .email:
            return DSIcons.Communication.email
        case .version:
            return DSIcons.Status.info
        case .twitter:
            return DSIcons.Status.info
        case .github:
            return DSIcons.Status.info
        case .releaseNotes:
            return DSIcons.File.document
        case .logs:
            return DSIcons.System.list
        case .inspector:
            return DSIcons.Jarvis.inspector
        case .preferences:
            return DSIcons.Jarvis.preferences
        case .app:
            return DSIcons.System.apple
        }
    }

    private var iconColor: Color {
        switch item.icon {
        case .star, .app:
            return DSColor.Success.success100
        case .inspector, .preferences, .logs:
            return DSColor.Extra.jarvisBlue
        default:
            return DSColor.Primary.primary60
        }
    }

    private var iconGradient: LinearGradient {
        switch item.icon {
        case .logs, .inspector, .preferences:
            return LinearGradient(
                colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [iconColor, iconColor],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // MARK: - Trailing View

    @ViewBuilder
    private var trailingView: some View {
        if let value = item.value {
            DSText(
                value,
                style: .bodySmall,
                color: DSColor.Neutral.neutral100
            )
        }

        if item.type == .navigate || item.type == .externalLink {
            DSIcons.Navigation.forward
                .font(.system(size: DSIconSize.s))
                .foregroundStyle(
                    item.isEnabled
                        ? iconGradient
                        : LinearGradient(
                            colors: [DSColor.Neutral.neutral60, DSColor.Neutral.neutral60],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Settings Item Row") {
    VStack(spacing: 0) {
        SettingsItemRow(
            item: SettingsItem(
                id: "1",
                title: "Version",
                value: "1.0.0 (1)",
                icon: .version,
                type: .info,
                action: .version
            ),
            onTap: {}
        )

        Divider()

        SettingsItemRow(
            item: SettingsItem(
                id: "2",
                title: "Inspector",
                description: "Manage network requests",
                icon: .inspector,
                type: .navigate,
                action: .navigateToInspector
            ),
            onTap: {}
        )

        Divider()

        SettingsItemRow(
            item: SettingsItem(
                id: "3",
                title: "Documentation",
                description: "View complete documentation",
                icon: .link,
                type: .externalLink,
                action: .openUrl("https://example.com")
            ),
            onTap: {}
        )

        Divider()

        SettingsItemRow(
            item: SettingsItem(
                id: "4",
                title: "Logging (Coming soon)",
                description: "Manage application logs",
                icon: .logs,
                type: .navigate,
                action: .navigateToLogging,
                isEnabled: false
            ),
            onTap: {}
        )
    }
    .background(DSColor.Extra.background0)
}
#endif
