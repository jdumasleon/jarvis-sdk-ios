//
//  DSEmptyState.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import SwiftUI
import JarvisDesignSystem

// MARK: - Empty State

public struct DSEmptyState: View {
    let icon: Image
    let title: String
    let description: String
    let primaryAction: (String, () -> Void)?

    public init(
        icon: Image,
        title: String,
        description: String,
        primaryAction: (String, () -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.primaryAction = primaryAction
    }

    public var body: some View {
        VStack(spacing: DSSpacing.m) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(DSColor.Neutral.neutral60)

            Text(title)
                .dsTextStyle(.titleMedium)
                .foregroundColor(DSColor.Neutral.neutral100)

            Text(description)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
                .multilineTextAlignment(.center)
                .dsPadding(.horizontal, DSSpacing.l)

            if let (actionTitle, action) = primaryAction {
                DSButton(
                    actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dsPadding(DSSpacing.l)
    }
}
