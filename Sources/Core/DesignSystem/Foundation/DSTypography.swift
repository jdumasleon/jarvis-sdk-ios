import SwiftUI

/// Design System Typography - consistent text styles across the app
public struct DSTypography {

    // MARK: - Display Typography (Large headers, hero text)
    public struct Display {
        public static let large = Font.system(size: 57, weight: .regular, design: .default)
        public static let medium = Font.system(size: 45, weight: .regular, design: .default)
        public static let small = Font.system(size: 36, weight: .regular, design: .default)
    }

    // MARK: - Headline Typography (Section headers, page titles)
    public struct Headline {
        public static let large = Font.system(size: 32, weight: .regular, design: .default)
        public static let medium = Font.system(size: 28, weight: .regular, design: .default)
        public static let small = Font.system(size: 24, weight: .regular, design: .default)
    }

    // MARK: - Title Typography (Component headers, card titles)
    public struct Title {
        public static let large = Font.system(size: 22, weight: .medium, design: .default)
        public static let medium = Font.system(size: 16, weight: .medium, design: .default)
        public static let small = Font.system(size: 14, weight: .medium, design: .default)
    }

    // MARK: - Body Typography (Main content, paragraphs)
    public struct Body {
        public static let large = Font.system(size: 16, weight: .regular, design: .default)
        public static let medium = Font.system(size: 14, weight: .regular, design: .default)
        public static let small = Font.system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Label Typography (Form labels, UI labels)
    public struct Label {
        public static let large = Font.system(size: 14, weight: .medium, design: .default)
        public static let medium = Font.system(size: 12, weight: .medium, design: .default)
        public static let small = Font.system(size: 11, weight: .medium, design: .default)
    }
}

// MARK: - Font Weight Extensions
public extension Font.Weight {
    static let extraLight = Font.Weight.ultraLight
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    static let heavy = Font.Weight.heavy
    static let black = Font.Weight.black
}

// MARK: - Typography Styles with Line Height
public struct DSTextStyle {
    public let font: Font
    public let lineHeight: CGFloat
    public let letterSpacing: CGFloat
    public let fontSize: CGFloat

    public init(font: Font, fontSize: CGFloat, lineHeight: CGFloat, letterSpacing: CGFloat = 0) {
        self.font = font
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

public extension DSTextStyle {
    // Display
    static let displayLarge  = DSTextStyle(font: DSTypography.Display.large,  fontSize: 57, lineHeight: 64)
    static let displayMedium = DSTextStyle(font: DSTypography.Display.medium, fontSize: 45, lineHeight: 52)
    static let displaySmall  = DSTextStyle(font: DSTypography.Display.small,  fontSize: 36, lineHeight: 44)

    // Headline
    static let headlineLarge  = DSTextStyle(font: DSTypography.Headline.large,  fontSize: 32, lineHeight: 40)
    static let headlineMedium = DSTextStyle(font: DSTypography.Headline.medium, fontSize: 28, lineHeight: 36)
    static let headlineSmall  = DSTextStyle(font: DSTypography.Headline.small,  fontSize: 24, lineHeight: 32)

    // Title
    static let titleLarge  = DSTextStyle(font: DSTypography.Title.large,  fontSize: 22, lineHeight: 28)
    static let titleMedium = DSTextStyle(font: DSTypography.Title.medium, fontSize: 16, lineHeight: 24)
    static let titleSmall  = DSTextStyle(font: DSTypography.Title.small,  fontSize: 14, lineHeight: 20)

    // Body
    static let bodyLarge  = DSTextStyle(font: DSTypography.Body.large,  fontSize: 16, lineHeight: 24)
    static let bodyMedium = DSTextStyle(font: DSTypography.Body.medium, fontSize: 14, lineHeight: 20)
    static let bodySmall  = DSTextStyle(font: DSTypography.Body.small,  fontSize: 12, lineHeight: 16)

    // Label
    static let labelLarge  = DSTextStyle(font: DSTypography.Label.large,  fontSize: 14, lineHeight: 20)
    static let labelMedium = DSTextStyle(font: DSTypography.Label.medium, fontSize: 12, lineHeight: 16)
    static let labelSmall  = DSTextStyle(font: DSTypography.Label.small,  fontSize: 11, lineHeight: 16, letterSpacing: 0.5)

}

public extension Text {
    func setTextStyle(_ style: DSTextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(max(0, style.lineHeight - style.fontSize))
            .kerning(style.letterSpacing)
    }
}

// MARK: - Preview Helper
#if DEBUG
public struct DSTypographyPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Group {
                    Section("Display") {
                        Text("Display Large").setTextStyle(.displayLarge)
                        Text("Display Medium").setTextStyle(.displayMedium)
                        Text("Display Small").setTextStyle(.displaySmall)
                    }

                    Section("Headlines") {
                        Text("Headline Large").setTextStyle(.headlineLarge)
                        Text("Headline Medium").setTextStyle(.headlineMedium)
                        Text("Headline Small").setTextStyle(.headlineSmall)
                    }

                    Section("Titles") {
                        Text("Title Large").setTextStyle(.titleLarge)
                        Text("Title Medium").setTextStyle(.titleMedium)
                        Text("Title Small").setTextStyle(.titleSmall)
                    }

                    Section("Body") {
                        Text("Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").setTextStyle(.bodyLarge)
                        Text("Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").setTextStyle(.bodyMedium)
                        Text("Body Small - Lorem ipsum dolor sit amet, consectetur adipiscing elit.").setTextStyle(.bodySmall)
                    }

                    Section("Labels") {
                        Text("Label Large").setTextStyle(.labelLarge)
                        Text("Label Medium").setTextStyle(.labelMedium)
                        Text("Label Small").setTextStyle(.labelSmall)
                    }

                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

@available(iOS 17.0, *)
#Preview("Typography System") {
    DSTypographyPreview()
}
#endif
