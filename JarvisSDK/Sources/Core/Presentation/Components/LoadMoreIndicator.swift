//
//  LoadMoreIndicator.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import SwiftUI
import JarvisDesignSystem

// MARK: - Load More Indicator

public struct LoadMoreIndicator: View {
    let isLoading: Bool
    let message: String

    public init(isLoading: Bool = false, message: String = "Loading more...") {
        self.isLoading = isLoading
        self.message = message
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
            }

            Text(message)
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(maxWidth: .infinity)
        .dsPadding(.vertical, DSSpacing.m)
    }
}
