import SwiftUI

/// Design System Elevation/Shadow - consistent shadow styles
public struct DSElevation {
    public static let none = 0.0
    public static let level1 = 1.0
    public static let level2 = 2.0
    public static let level3 = 4.0
    public static let level4 = 8.0
    public static let level5 = 16.0

    // Semantic shadow styles
    public struct Shadow {
        public static let subtle = (
            color: DSColor.Neutral.neutral100.opacity(0.04),
            radius: CGFloat(1),
            offset: CGSize(width: 0, height: 1)
        )

        public static let small = (
            color: DSColor.Neutral.neutral100.opacity(0.06),
            radius: CGFloat(2),
            offset: CGSize(width: 0, height: 1)
        )

        public static let medium = (
            color: DSColor.Neutral.neutral100.opacity(0.08),
            radius: CGFloat(4),
            offset: CGSize(width: 0, height: 2)
        )

        public static let large = (
            color: DSColor.Neutral.neutral100.opacity(0.10),
            radius: CGFloat(8),
            offset: CGSize(width: 0, height: 4)
        )

        public static let extraLarge = (
            color: DSColor.Neutral.neutral100.opacity(0.12),
            radius: CGFloat(16),
            offset: CGSize(width: 0, height: 8)
        )
    }
}

// MARK: - Shadow Extensions

public extension View {
    // MARK: - Shadow Extensions
    func dsShadow(_ level: (color: Color, radius: CGFloat, offset: CGSize)) -> some View {
        shadow(color: level.color, radius: level.radius, x: level.offset.width, y: level.offset.height)
    }

    func dsShadowSubtle() -> some View {
        dsShadow(DSElevation.Shadow.subtle)
    }

    func dsShadowSmall() -> some View {
        dsShadow(DSElevation.Shadow.small)
    }

    func dsShadowMedium() -> some View {
        dsShadow(DSElevation.Shadow.medium)
    }

    func dsShadowLarge() -> some View {
        dsShadow(DSElevation.Shadow.large)
    }

    func dsShadowExtraLarge() -> some View {
        dsShadow(DSElevation.Shadow.extraLarge)
    }
}

#Preview("DSElevation Shadows") {
    VStack(spacing: 24) {
        shadowExample(title: "Subtle", style: DSElevation.Shadow.subtle)
        shadowExample(title: "Small", style: DSElevation.Shadow.small)
        shadowExample(title: "Medium", style: DSElevation.Shadow.medium)
        shadowExample(title: "Large", style: DSElevation.Shadow.large)
        shadowExample(title: "Extra Large", style: DSElevation.Shadow.extraLarge)
    }
    .padding(40)
    .background(Color(UIColor.systemGroupedBackground))
}

@ViewBuilder
private func shadowExample(title: String, style: (color: Color, radius: CGFloat, offset: CGSize)) -> some View {
    VStack(spacing: 8) {
        Text(title)
            .font(.headline)
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .frame(width: 180, height: 80)
            .dsShadow(style)
    }
}
