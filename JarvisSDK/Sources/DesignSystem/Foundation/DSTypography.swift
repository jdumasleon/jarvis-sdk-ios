import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Dynamic Type Support Helper Extensions

#if canImport(UIKit)
/// Extension to convert SwiftUI Font.Weight to UIFont.Weight
private extension Font.Weight {
    func toUIFontWeight() -> UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}
#endif

/// Extension to create fonts that scale with Dynamic Type
public extension Font {
    /// Creates a font that scales with Dynamic Type based on a reference text style
    /// - Parameters:
    ///   - size: The base font size (used at default content size)
    ///   - weight: The font weight
    ///   - design: The font design
    ///   - textStyle: The reference UIFont.TextStyle for scaling behavior
    /// - Returns: A font that scales with Dynamic Type
    static func scaledFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        #if canImport(UIKit)
        // Use UIFontMetrics for proper Dynamic Type scaling
        let metrics = UIFontMetrics(forTextStyle: textStyle.toUIFontTextStyle())
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle.toUIFontTextStyle())
        let uiFont = UIFont.systemFont(ofSize: size, weight: weight.toUIFontWeight())
        let scaledFont = metrics.scaledFont(for: uiFont)
        return Font(scaledFont)
        #else
        // Fallback for non-UIKit platforms
        return Font.system(size: size, weight: weight, design: design)
        #endif
    }
}

#if canImport(UIKit)
/// Extension to convert SwiftUI Font.TextStyle to UIFont.TextStyle
private extension Font.TextStyle {
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }
}
#endif

// MARK: - Design System Typography

/// Design System Typography - consistent text styles across the app with Dynamic Type support
public struct DSTypography {

    // MARK: - Display Typography (Large headers, hero text)
    public struct Display {
        /// Large display text (57pt base, scales with largeTitle)
        public static let large = Font.scaledFont(size: 57, weight: .regular, relativeTo: .largeTitle)

        /// Medium display text (45pt base, scales with largeTitle)
        public static let medium = Font.scaledFont(size: 45, weight: .regular, relativeTo: .largeTitle)

        /// Small display text (36pt base, scales with title)
        public static let small = Font.scaledFont(size: 36, weight: .regular, relativeTo: .title)
    }

    // MARK: - Headline Typography (Section headers, page titles)
    public struct Headline {
        /// Large headline (32pt base, scales with title2)
        public static let large = Font.scaledFont(size: 32, weight: .regular, relativeTo: .title2)

        /// Medium headline (28pt base, scales with title3)
        public static let medium = Font.scaledFont(size: 28, weight: .regular, relativeTo: .title3)

        /// Small headline (24pt base, scales with headline)
        public static let small = Font.scaledFont(size: 24, weight: .regular, relativeTo: .headline)
    }

    // MARK: - Title Typography (Component headers, card titles)
    public struct Title {
        /// Large title (22pt base, scales with headline)
        public static let large = Font.scaledFont(size: 22, weight: .medium, relativeTo: .headline)

        /// Medium title (16pt base, scales with subheadline)
        public static let medium = Font.scaledFont(size: 16, weight: .medium, relativeTo: .subheadline)

        /// Small title (14pt base, scales with subheadline)
        public static let small = Font.scaledFont(size: 14, weight: .medium, relativeTo: .subheadline)
    }

    // MARK: - Body Typography (Main content, paragraphs)
    public struct Body {
        /// Large body text (16pt base, scales with body)
        public static let large = Font.scaledFont(size: 16, weight: .regular, relativeTo: .body)

        /// Medium body text (14pt base, scales with callout)
        public static let medium = Font.scaledFont(size: 14, weight: .regular, relativeTo: .callout)

        /// Small body text (12pt base, scales with footnote)
        public static let small = Font.scaledFont(size: 12, weight: .regular, relativeTo: .footnote)
    }

    // MARK: - Label Typography (Form labels, UI labels)
    public struct Label {
        /// Large label (14pt base, scales with callout)
        public static let large = Font.scaledFont(size: 14, weight: .medium, relativeTo: .callout)

        /// Medium label (12pt base, scales with footnote)
        public static let medium = Font.scaledFont(size: 12, weight: .medium, relativeTo: .footnote)

        /// Small label (11pt base, scales with caption)
        public static let small = Font.scaledFont(size: 11, weight: .medium, relativeTo: .caption)
    }
}

// MARK: - Typography Styles with Line Height and Dynamic Type

/// A text style that includes font, line height, and letter spacing with Dynamic Type support
public struct DSTextStyle {
    public let font: Font
    public let baseSize: CGFloat
    public let lineHeightMultiplier: CGFloat
    public let letterSpacing: CGFloat
    public let textStyle: Font.TextStyle

    public init(
        font: Font,
        baseSize: CGFloat,
        lineHeightMultiplier: CGFloat = 1.4,
        letterSpacing: CGFloat = 0,
        textStyle: Font.TextStyle
    ) {
        self.font = font
        self.baseSize = baseSize
        self.lineHeightMultiplier = lineHeightMultiplier
        self.letterSpacing = letterSpacing
        self.textStyle = textStyle
    }

    /// Calculates line height based on base size and multiplier
    public var lineHeight: CGFloat {
        baseSize * lineHeightMultiplier
    }
}

public extension DSTextStyle {
    // Display styles
    static let displayLarge = DSTextStyle(
        font: DSTypography.Display.large,
        baseSize: 57,
        lineHeightMultiplier: 1.12,
        textStyle: .largeTitle
    )

    static let displayMedium = DSTextStyle(
        font: DSTypography.Display.medium,
        baseSize: 45,
        lineHeightMultiplier: 1.16,
        textStyle: .largeTitle
    )

    static let displaySmall = DSTextStyle(
        font: DSTypography.Display.small,
        baseSize: 36,
        lineHeightMultiplier: 1.22,
        textStyle: .title
    )

    // Headline styles
    static let headlineLarge = DSTextStyle(
        font: DSTypography.Headline.large,
        baseSize: 32,
        lineHeightMultiplier: 1.25,
        textStyle: .title2
    )

    static let headlineMedium = DSTextStyle(
        font: DSTypography.Headline.medium,
        baseSize: 28,
        lineHeightMultiplier: 1.29,
        textStyle: .title3
    )

    static let headlineSmall = DSTextStyle(
        font: DSTypography.Headline.small,
        baseSize: 24,
        lineHeightMultiplier: 1.33,
        textStyle: .headline
    )

    // Title styles
    static let titleLarge = DSTextStyle(
        font: DSTypography.Title.large,
        baseSize: 22,
        lineHeightMultiplier: 1.27,
        textStyle: .headline
    )

    static let titleMedium = DSTextStyle(
        font: DSTypography.Title.medium,
        baseSize: 16,
        lineHeightMultiplier: 1.5,
        textStyle: .subheadline
    )

    static let titleSmall = DSTextStyle(
        font: DSTypography.Title.small,
        baseSize: 14,
        lineHeightMultiplier: 1.43,
        textStyle: .subheadline
    )

    // Body styles
    static let bodyLarge = DSTextStyle(
        font: DSTypography.Body.large,
        baseSize: 16,
        lineHeightMultiplier: 1.5,
        textStyle: .body
    )

    static let bodyMedium = DSTextStyle(
        font: DSTypography.Body.medium,
        baseSize: 14,
        lineHeightMultiplier: 1.43,
        textStyle: .callout
    )

    static let bodySmall = DSTextStyle(
        font: DSTypography.Body.small,
        baseSize: 12,
        lineHeightMultiplier: 1.33,
        textStyle: .footnote
    )

    // Label styles
    static let labelLarge = DSTextStyle(
        font: DSTypography.Label.large,
        baseSize: 14,
        lineHeightMultiplier: 1.43,
        textStyle: .callout
    )

    static let labelMedium = DSTextStyle(
        font: DSTypography.Label.medium,
        baseSize: 12,
        lineHeightMultiplier: 1.33,
        textStyle: .footnote
    )

    static let labelSmall = DSTextStyle(
        font: DSTypography.Label.small,
        baseSize: 11,
        lineHeightMultiplier: 1.45,
        letterSpacing: 0.5,
        textStyle: .caption
    )
}

// MARK: - Font Style View Modifier

/// ViewModifier that applies design system text styles
public struct DSFontStyleModifier: ViewModifier {
    let style: DSTextStyle

    public func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(max(0, style.lineHeight - style.baseSize))
            .kerning(style.letterSpacing)
    }
}

public extension View {
    /// Applies a design system text style with proper line spacing and kerning
    /// - Parameter style: The DSTextStyle to apply
    /// - Returns: A view with the text style applied
    func dsTextStyle(_ style: DSTextStyle) -> some View {
        modifier(DSFontStyleModifier(style: style))
    }
}

// MARK: - Preview Helper
#if DEBUG
public struct DSTypographyPreview: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Dynamic Type info
                Text("Current Dynamic Type: \(String(describing: dynamicTypeSize))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                Divider()

                Group {
                    Section("Display") {
                        Text("Display Large").dsTextStyle(.displayLarge)
                        Text("Display Medium").dsTextStyle(.displayMedium)
                        Text("Display Small").dsTextStyle(.displaySmall)
                    }

                    Divider()

                    Section("Headlines") {
                        Text("Headline Large").dsTextStyle(.headlineLarge)
                        Text("Headline Medium").dsTextStyle(.headlineMedium)
                        Text("Headline Small").dsTextStyle(.headlineSmall)
                    }

                    Divider()

                    Section("Titles") {
                        Text("Title Large").dsTextStyle(.titleLarge)
                        Text("Title Medium").dsTextStyle(.titleMedium)
                        Text("Title Small").dsTextStyle(.titleSmall)
                    }

                    Divider()

                    Section("Body") {
                        Text("Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").dsTextStyle(.bodyLarge)
                        Text("Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").dsTextStyle(.bodyMedium)
                        Text("Body Small - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").dsTextStyle(.bodySmall)
                    }

                    Divider()

                    Section("Labels") {
                        Text("Label Large").dsTextStyle(.labelLarge)
                        Text("Label Medium").dsTextStyle(.labelMedium)
                        Text("Label Small").dsTextStyle(.labelSmall)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Typography System")
    }
}

@available(iOS 17.0, *)
#Preview("Typography System") {
    DSTypographyPreview()
}

@available(iOS 17.0, *)
#Preview("Typography - Large Text") {
    DSTypographyPreview()
        .environment(\.dynamicTypeSize, .xxxLarge)
}

@available(iOS 17.0, *)
#Preview("Typography - Small Text") {
    DSTypographyPreview()
        .environment(\.dynamicTypeSize, .xSmall)
}
#endif
