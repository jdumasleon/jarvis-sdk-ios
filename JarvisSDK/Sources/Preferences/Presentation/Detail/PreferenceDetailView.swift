//
//  PreferenceDetailView.swift
//  JarvisSDK
//
//  Preference detail view showing full information
//

import SwiftUI
import JarvisDesignSystem
import JarvisPreferencesDomain

/// Detail view for a single preference
struct PreferenceDetailView: View {
    let preference: Preference

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Key Section
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    DSText(
                        "Key",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral80
                    )
                    DSText(
                        preference.key,
                        style: .bodyLarge,
                        color: DSColor.Neutral.neutral100
                    )
                }

                Divider()

                // Value Section
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    DSText(
                        "Value",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral80
                    )
                    DSText(
                        String(describing: preference.value),
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                }

                Divider()

                // Type Section
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    DSText(
                        "Type",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral80
                    )
                    DSText(
                        preference.type,
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                }

                Divider()

                // Source Section
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    DSText(
                        "Source",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral80
                    )
                    DSText(
                        preference.source.rawValue,
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                }

                if let suite = preference.suiteName {
                    Divider()

                    // Suite Name Section
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSText(
                            "Suite Name",
                            style: .labelSmall,
                            color: DSColor.Neutral.neutral80
                        )
                        DSText(
                            suite,
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral100
                        )
                    }
                }

                Divider()

                // Timestamp Section
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    DSText(
                        "Last Modified",
                        style: .labelSmall,
                        color: DSColor.Neutral.neutral80
                    )
                    DSText(
                        formatTimestamp(preference.timestamp),
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100
                    )
                }
            }
            .padding(DSSpacing.m)
        }
        .background(DSColor.Extra.background0)
        .navigationTitle("Preference Detail")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
