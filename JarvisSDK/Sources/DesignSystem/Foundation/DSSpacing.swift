import SwiftUI

/// Design System Spacing - consistent spacing values across the app
public struct DSSpacing {

    // MARK: - Base Spacing Scale (8pt grid system)
    public static let none: CGFloat = 0
    public static let xxxs: CGFloat = 2    // 0.25 * base
    public static let xxs: CGFloat = 4     // 0.5 * base
    public static let xs: CGFloat = 8      // 1 * base
    public static let s: CGFloat = 12      // 1.5 * base
    public static let m: CGFloat = 16      // 2 * base
    public static let l: CGFloat = 24      // 3 * base
    public static let xl: CGFloat = 32     // 4 * base
    public static let xxl: CGFloat = 48    // 6 * base
    public static let xxxl: CGFloat = 64   // 8 * base
    public static let xxxxl: CGFloat = 96  // 12 * base
}

// MARK: - Spacing Extensions

public extension EdgeInsets {
    static func ds(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }

    static func dsHorizontal(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
    }

    static func dsVertical(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
    }

    static func ds(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> EdgeInsets {
        EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

public extension View {
    // MARK: - Padding Extensions
    func dsPadding(_ value: CGFloat) -> some View {
        padding(value)
    }

    func dsPadding(_ edges: Edge.Set, _ value: CGFloat) -> some View {
        padding(edges, value)
    }

    func dsContainerPadding() -> some View {
        padding(DSLayout.containerPadding)
    }
}

// MARK: - Preview Helper
#if DEBUG
public struct DSSpacingPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Section("Spacing Scale") {
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        SpacingExample("None", DSSpacing.none)
                        SpacingExample("XXXs", DSSpacing.xxxs)
                        SpacingExample("XXs", DSSpacing.xxs)
                        SpacingExample("Xs", DSSpacing.xs)
                        SpacingExample("S", DSSpacing.s)
                        SpacingExample("M", DSSpacing.m)
                        SpacingExample("L", DSSpacing.l)
                        SpacingExample("XL", DSSpacing.xl)
                        SpacingExample("XXL", DSSpacing.xxl)
                        SpacingExample("XXXL", DSSpacing.xxxl)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func SpacingExample(_ name: String, _ value: CGFloat) -> some View {
        HStack {
            Text(name).dsTextStyle(.labelMedium)
            Rectangle()
                .fill(DSColor.Primary.primary100)
                .frame(width: value, height: 10)
                .dsCornerRadius(DSRadius.m)
            Text("\(Int(value))pt").dsTextStyle(.labelSmall)
        }
    }
}

@available(iOS 17.0, *)
#Preview("Spacing") {
    DSSpacingPreview()
}
#endif
