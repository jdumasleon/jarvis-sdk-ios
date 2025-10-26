import SwiftUI

/// Design System Dimensions
public struct DSDimensions {

    // MARK: - Main Dimensions System (matching Android DSDimensions.kt)
    public static let none: CGFloat = 0         // DimensionsNone = 0.dp
    public static let xxxs: CGFloat = 1         // DimensionsXXXS = 1.dp
    public static let xxs: CGFloat = 2          // DimensionsXXS = 2.dp
    public static let xs: CGFloat = 4           // DimensionsXS = 4.dp
    public static let s: CGFloat = 8            // DimensionsS = 8.dp
    public static let m: CGFloat = 16           // DimensionsM = 16.dp
    public static let l: CGFloat = 24           // DimensionsL = 24.dp
    public static let xl: CGFloat = 32          // DimensionsXL = 32.dp
    public static let xxl: CGFloat = 40         // DimensionsXXL = 40.dp
    public static let xxxl: CGFloat = 48        // DimensionsXXXL = 48.dp
    public static let xxxxl: CGFloat = 56       // DimensionsXXXXL = 56.dp
    public static let xxxxxl: CGFloat = 64      // DimensionsXXXXXL = 64.dp
    public static let xxxxxxl: CGFloat = 80     // DimensionsXXXXXXL = 80.dp
    public static let xxxxxxxl: CGFloat = 100   // DimensionsXXXXXXXL = 100.dp
    public static let xxxxxxxxl: CGFloat = 150  // DimensionsXXXXXXXXL = 150.dp
    public static let xxxxxxxxxl: CGFloat = 200 // DimensionsXXXXXXXXXL = 200.dp
}

// MARK: - Layout Values

public struct DSLayoutValues {
    public static let toolbarHeight: CGFloat = 44
    public static let tabBarHeight: CGFloat = 49
    public static let navigationBarHeight: CGFloat = 44
    public static let safeAreaInsetBottom: CGFloat = 34  // iPhone with home indicator
    public static let safeAreaInsetTop: CGFloat = 44     // iPhone with notch/dynamic island
}

// MARK: - Dimension Extensions

public extension View {
    // MARK: - Dimension-based Frame Extensions
    func dsFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        frame(width: width, height: height)
    }

    func dsSize(_ size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func dsMinFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        frame(minWidth: width, minHeight: height)
    }

    func dsMaxFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        frame(maxWidth: width, maxHeight: height)
    }
}

// MARK: - Preview Helper
#if DEBUG
public struct DSDimensionsPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Section("Main Dimensions") {
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        DimensionExample("None", DSDimensions.none)
                        DimensionExample("XXXS", DSDimensions.xxxs)
                        DimensionExample("XXS", DSDimensions.xxs)
                        DimensionExample("XS", DSDimensions.xs)
                        DimensionExample("S", DSDimensions.s)
                        DimensionExample("M", DSDimensions.m)
                        DimensionExample("L", DSDimensions.l)
                        DimensionExample("XL", DSDimensions.xl)
                        DimensionExample("XXL", DSDimensions.xxl)
                        DimensionExample("XXXL", DSDimensions.xxxl)
                        DimensionExample("XXXXL", DSDimensions.xxxxl)
                        DimensionExample("XXXXXL", DSDimensions.xxxxxl)
                        DimensionExample("XXXXXXL", DSDimensions.xxxxxxl)
                        DimensionExample("XXXXXXXL", DSDimensions.xxxxxxxl)
                        DimensionExample("XXXXXXXXL", DSDimensions.xxxxxxxxl)
                        DimensionExample("XXXXXXXXXL", DSDimensions.xxxxxxxxxl)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func DimensionExample(_ name: String, _ value: CGFloat) -> some View {
        HStack {
            Text(name).dsTextStyle(.labelMedium)
            Rectangle()
                .fill(DSColor.Primary.primary60)
                .frame(width: value, height: 10)
                .dsCornerRadius(value)
            Text("\(Int(value))pt").dsTextStyle(.labelSmall)
        }
    }

    private func RadiusExample(_ name: String, _ value: CGFloat) -> some View {
        HStack {
            Text(name).dsTextStyle(.labelMedium)
            Rectangle()
                .fill(DSColor.Primary.primary60)
                .frame(width: 60, height: 40)
                .dsCornerRadius(value)
            Text("\(Int(value))pt").dsTextStyle(.labelSmall)
        }
    }
}

@available(iOS 17.0, *)
#Preview("Dimensions") {
    DSDimensionsPreview()
}
#endif
