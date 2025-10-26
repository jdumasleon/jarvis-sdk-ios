import SwiftUI

/// Design System Border Radius - consistent corner radius values
public struct DSRadius {
    public static let none: CGFloat = 0
    public static let xs: CGFloat = 2
    public static let s: CGFloat = 4
    public static let m: CGFloat = 8
    public static let l: CGFloat = 12
    public static let xl: CGFloat = 16
    public static let xxl: CGFloat = 24
    public static let round: CGFloat = 9999 // For fully rounded components
}

/// Corner specification for selective radius application
public struct CornerRadius {
    let topLeading: CGFloat
    let topTrailing: CGFloat
    let bottomLeading: CGFloat
    let bottomTrailing: CGFloat

    public static func all(_ radius: CGFloat) -> CornerRadius {
        CornerRadius(topLeading: radius, topTrailing: radius, bottomLeading: radius, bottomTrailing: radius)
    }

    public static func top(_ radius: CGFloat) -> CornerRadius {
        CornerRadius(topLeading: radius, topTrailing: radius, bottomLeading: 0, bottomTrailing: 0)
    }

    public static func bottom(_ radius: CGFloat) -> CornerRadius {
        CornerRadius(topLeading: 0, topTrailing: 0, bottomLeading: radius, bottomTrailing: radius)
    }

    public static func leading(_ radius: CGFloat) -> CornerRadius {
        CornerRadius(topLeading: radius, topTrailing: 0, bottomLeading: radius, bottomTrailing: 0)
    }

    public static func trailing(_ radius: CGFloat) -> CornerRadius {
        CornerRadius(topLeading: 0, topTrailing: radius, bottomLeading: 0, bottomTrailing: radius)
    }
}

// MARK: - Corner Radius Extensions
public extension View {
    /// Apply uniform corner radius
    func dsCornerRadius(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }

    /// Apply selective corner radius
    func dsCornerRadius(_ radii: CornerRadius) -> some View {
        clipShape(UnevenRoundedRectangle(
            topLeadingRadius: radii.topLeading,
            bottomLeadingRadius: radii.bottomLeading,
            bottomTrailingRadius: radii.bottomTrailing,
            topTrailingRadius: radii.topTrailing
        ))
    }
}
