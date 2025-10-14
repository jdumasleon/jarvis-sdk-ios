import SwiftUI

/// Design System Border Width - consistent border thickness
public struct DSBorderWidth {
    public static let none: CGFloat = 0
    public static let thin: CGFloat = 0.5
    public static let regular: CGFloat = 1
    public static let thick: CGFloat = 2
    public static let heavy: CGFloat = 4
}

// MARK: - Border Extensions

public extension View {
    // MARK: - Border Extensions
    func dsBorder(_ color: Color = DSColor.Surface.border, width: CGFloat = DSBorderWidth.regular) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(color, lineWidth: width)
        )
    }

    func dsBorder(_ color: Color = DSColor.Surface.border, width: CGFloat = DSBorderWidth.regular, radius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(color, lineWidth: width)
        )
    }
}