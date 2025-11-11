//
//  DSFilterChip.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 7/11/25.
//

import SwiftUI
import JarvisDesignSystem

// MARK: - Filter Chip

public struct DSFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if isSelected {
                    DSIcons.Status.check
                        .font(.system(size: DSDimensions.m))
                        .foregroundColor(
                            DSColor.Extra.white
                        )
                }
                
                Text(title)
                    .dsTextStyle(.labelSmall)
                    .foregroundColor(isSelected ? DSColor.Extra.white : DSColor.Neutral.neutral80)
            }
            .dsPadding(.horizontal, DSSpacing.s)
            .dsPadding(.vertical, DSSpacing.xs)
            .background(
                isSelected ?
                    LinearGradient(
                        colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [DSColor.Extra.white, DSColor.Extra.white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .dsCornerRadius(DSRadius.round)
        }
        .dsBorder(
            DSColor.Neutral.neutral80,
            width: DSBorderWidth.thin,
            radius: DSRadius.round
        )
        
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct DSFilterChip_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: DSSpacing.m) {
                DSFilterChip(
                    title: "Selected",
                    isSelected: true,
                    action: {}
                )

                DSFilterChip(
                    title: "Unselected",
                    isSelected: false,
                    action: {}
                )
            }
            .previewLayout(.sizeThatFits)
            .padding()
            .background(DSColor.Extra.background0)
            .previewDisplayName("DSFilterChip States")
        }
    }
}
#endif
