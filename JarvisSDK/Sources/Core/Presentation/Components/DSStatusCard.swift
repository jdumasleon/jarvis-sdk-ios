//
//  DSStatusCard.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import SwiftUI
import DesignSystem

// MARK: - Status Card

public struct DSStatusCard: View {
    public enum Status {
        case error
        case warning
        case info
    }

    let status: Status
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    public init(
        status: Status,
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        self.status = status
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(statusColor)

                Text(title)
                    .dsTextStyle(.titleSmall)
                    .foregroundColor(DSColor.Neutral.neutral100)
            }

            Text(message)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)

            DSButton(
                actionTitle,
                style: .secondary,
                size: .small,
                action: action
            )
        }
        .dsPadding(DSSpacing.m)
        .background(statusColor.opacity(0.1))
        .dsCornerRadius(DSRadius.m)
    }

    private var statusColor: Color {
        switch status {
        case .error: return DSColor.Error.error100
        case .warning: return DSColor.Warning.warning100
        case .info: return DSColor.Info.info100
        }
    }

    private var iconName: String {
        switch status {
        case .error: return "exclamationmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

