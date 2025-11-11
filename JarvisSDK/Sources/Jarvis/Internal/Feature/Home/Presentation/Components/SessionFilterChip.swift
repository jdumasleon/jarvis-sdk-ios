//
//  SessionFilterChip.swift
//  JarvisSDK
//
//  Session filter chip component
//

import SwiftUI
import JarvisDesignSystem

/// Session filter chip for toggling between filter options
struct SessionFilterChip: View {
    let filter: SessionFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: filter.icon)
                    .font(.system(size: 14, weight: .medium))

                Text(filter.displayName)
                    .dsTextStyle(.labelMedium)
            }
            .dsPadding(.horizontal, DSSpacing.m)
            .dsPadding(.vertical, DSSpacing.s)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [DSColor.Primary.primary60, DSColor.Primary.primary80],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .foregroundColor(isSelected ? DSColor.Extra.white : DSColor.Neutral.neutral80)
            .dsCornerRadius(DSRadius.m)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.m)
                    .stroke(isSelected ? Color.clear : DSColor.Neutral.neutral40, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

/// Extended session filter chip with description
struct SessionFilterChipExtended: View {
    let filter: SessionFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: filter.icon)
                        .font(.system(size: 16, weight: .medium))

                    Text(filter.displayName)
                        .dsTextStyle(.labelLarge)
                }

                Text(filter.description)
                    .dsTextStyle(.bodySmall)
                    .foregroundColor(isSelected ? DSColor.Extra.white.opacity(0.8) : DSColor.Neutral.neutral60)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsPadding(.all, DSSpacing.m)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [DSColor.Primary.primary60, DSColor.Primary.primary80],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        DSColor.Extra.white
                    }
                }
            )
            .foregroundColor(isSelected ? DSColor.Extra.white : DSColor.Neutral.neutral100)
            .dsCornerRadius(DSRadius.m)
            .shadow(
                color: isSelected ? DSColor.Primary.primary60.opacity(0.3) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 2,
                x: 0,
                y: isSelected ? 4 : 1
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Previews

#if DEBUG
struct SessionFilterChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DSSpacing.m) {
            HStack(spacing: DSSpacing.s) {
                SessionFilterChip(filter: .lastSession, isSelected: true, onTap: {})
                SessionFilterChip(filter: .last24Hours, isSelected: false, onTap: {})
            }

            Divider()

            VStack(spacing: DSSpacing.s) {
                SessionFilterChipExtended(filter: .lastSession, isSelected: true, onTap: {})
                SessionFilterChipExtended(filter: .last24Hours, isSelected: false, onTap: {})
            }
        }
        .dsPadding(.all, DSSpacing.l)
        .background(DSColor.Extra.background0)
    }
}
#endif
