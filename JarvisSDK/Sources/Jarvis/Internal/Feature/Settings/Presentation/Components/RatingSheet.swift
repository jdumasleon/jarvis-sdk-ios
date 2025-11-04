//
//  RatingSheet.swift
//  JarvisSDK
//
//  Rating bottom sheet for SDK feedback
//

import SwiftUI
import DesignSystem

/// Rating data model
public struct RatingData {
    public var stars: Int
    public var description: String
    public var isSubmitting: Bool

    public init(
        stars: Int = 0,
        description: String = "",
        isSubmitting: Bool = false
    ) {
        self.stars = stars
        self.description = description
        self.isSubmitting = isSubmitting
    }
}

/// Rating bottom sheet dialog for SDK feedback
public struct RatingSheet: View {
    let ratingData: RatingData
    let onRatingChange: (Int) -> Void
    let onDescriptionChange: (String) -> Void
    let onSubmit: () -> Void
    let onCancel: () -> Void

    public init(
        ratingData: RatingData,
        onRatingChange: @escaping (Int) -> Void,
        onDescriptionChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.ratingData = ratingData
        self.onRatingChange = onRatingChange
        self.onDescriptionChange = onDescriptionChange
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    // Title and Subtitle
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSText(
                            "Rate Jarvis SDK",
                            style: .titleLarge,
                            fontWeight: .bold
                        )

                        DSText(
                            "Help us improve by sharing your feedback",
                            style: .bodyMedium,
                            color: DSColor.Neutral.neutral100
                        )
                    }
                    .padding(.top, DSSpacing.m)
                    
                    // Star Rating
                    StarRating(
                        rating: ratingData.stars,
                        onRatingChange: onRatingChange
                    )
                    
                    // Description Input
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        DSText(
                            "Description (Optional)",
                            style: .labelMedium,
                            color: DSColor.Neutral.neutral100
                        )

                        TextEditor(text: Binding(
                            get: { ratingData.description },
                            set: { onDescriptionChange($0) }
                        ))
                        .frame(minHeight: 100)
                        .padding(DSSpacing.xs)
                        .background(DSColor.Extra.white)
                        .cornerRadius(DSRadius.s)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.s)
                                .stroke(DSColor.Neutral.neutral20, lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            if ratingData.description.isEmpty {
                                Text("Tell us what you think...")
                                    .foregroundColor(DSColor.Neutral.neutral60)
                                    .padding(.horizontal, DSSpacing.xs + 4)
                                    .padding(.vertical, DSSpacing.xs + 8)
                                    .allowsHitTesting(false)
                            }
                        }
                    }

                    // Buttons
                    VStack(spacing: DSSpacing.s) {
                        DSButton(
                            "Submit",
                            style: .primary,
                            size: .large,
                            isEnabled: ratingData.stars > 0 && !ratingData.isSubmitting,
                            isLoading: ratingData.isSubmitting,
                            action: {
                                // If description is empty, set it to "awesome" before submitting
                                if ratingData.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    onDescriptionChange("awesome")
                                }
                                onSubmit()
                            }
                        )

                        DSButton(
                            "Cancel",
                            style: .outline,
                            size: .large,
                            isEnabled: !ratingData.isSubmitting,
                            action: onCancel
                        )
                    }
                }
            }
            .padding(.horizontal, DSSpacing.m)
            .background(DSColor.Extra.background0)
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
    }
}

/// Star rating component
private struct StarRating: View {
    let rating: Int
    let onRatingChange: (Int) -> Void
    let maxStars: Int = 5

    var body: some View {
        HStack(spacing: DSSpacing.s) {
            ForEach(1...maxStars, id: \.self) { starIndex in
                let isSelected = starIndex <= rating

                DSIconButton(
                    icon: DSIcons.Action.starFilled,
                    size: .large,
                    tint: isSelected ? DSColor.Warning.warning100 : DSColor.Neutral.neutral60
                ) {
                    onRatingChange(starIndex)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Rating Sheet - Empty") {
    RatingSheet(
        ratingData: RatingData(),
        onRatingChange: { _ in },
        onDescriptionChange: { _ in },
        onSubmit: {},
        onCancel: {}
    )
}

#Preview("Rating Sheet - Filled") {
    RatingSheet(
        ratingData: RatingData(
            stars: 5,
            description: "Great SDK! Very helpful for debugging network issues.",
            isSubmitting: false
        ),
        onRatingChange: { _ in },
        onDescriptionChange: { _ in },
        onSubmit: {},
        onCancel: {}
    )
}

#Preview("Rating Sheet - Submitting") {
    RatingSheet(
        ratingData: RatingData(
            stars: 4,
            description: "Very useful tool for network debugging!",
            isSubmitting: true
        ),
        onRatingChange: { _ in },
        onDescriptionChange: { _ in },
        onSubmit: {},
        onCancel: {}
    )
}
#endif
