import SwiftUI

/// Design System Text component with built-in typography styles
///
/// DSText provides a convenient way to use design system typography without
/// manually applying font styles. It ensures consistent text rendering across
/// the app with proper Dynamic Type support.
///
/// Example usage:
/// ```swift
/// // Basic usage with style
/// DSText.titleLarge("Welcome to Jarvis")
///
/// // With custom color
/// DSText.bodyMedium("Network inspection enabled", color: DSColor.Success.success100)
///
/// // With alignment and line limit
/// DSText.bodySmall(
///     "Long text that needs to be truncated...",
///     alignment: .center,
///     lineLimit: 2
/// )
///
/// // Using the generic initializer
/// DSText("Custom text", style: .headlineLarge, color: DSColor.Primary.primary60)
/// ```
import SwiftUI

// MARK: - Foreground model (simple y compatible)
public enum DSTextForeground {
    case color(Color)
    case gradient(LinearGradient)
}

/// Design System Text component with built-in typography styles
///
/// Permite `color` o `gradient` como foreground. Si usas `gradient`,
/// se aplica mediante `overlay + mask`, por lo que funciona en iOS 15+.
public struct DSText: View {
    private let text: String
    private let style: DSTextStyle
    private let foreground: DSTextForeground?
    private let alignment: TextAlignment
    private let lineLimit: Int?
    private let truncationMode: Text.TruncationMode
    private let fontWeight: Font.Weight?

    // MARK: Init con color (backwards compatible)
    public init(
        _ text: String,
        style: DSTextStyle,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) {
        self.text = text
        self.style = style
        self.foreground = color.map { .color($0) }
        self.alignment = alignment
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
        self.fontWeight = fontWeight
    }

    // MARK: Init con gradient (nuevo y simple)
    public init(
        _ text: String,
        style: DSTextStyle,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) {
        self.text = text
        self.style = style
        self.foreground = .gradient(gradient)
        self.alignment = alignment
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
        self.fontWeight = fontWeight
    }

    @ViewBuilder
    public var body: some View {
        let base = Text(text)
            .dsTextStyle(style)
            .fontWeight(fontWeight)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .truncationMode(truncationMode)

        switch foreground {
        case .color(let c):
            base.foregroundColor(c)

        case .gradient(let g):
            // Truco universal: texto transparente + overlay gradiente + mask con el mismo texto
            base
                .foregroundColor(.clear)
                .overlay(g)
                .mask(base)

        case .none:
            base.foregroundColor(DSColor.Extra.black)
        }
    }
}

// MARK: - Convenience Initializers

public extension DSText {
    // MARK: Display (color)
    static func displayLarge(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displayLarge, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func displayMedium(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displayMedium, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func displaySmall(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displaySmall, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Display (gradient)
    static func displayLarge(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displayLarge, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func displayMedium(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displayMedium, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func displaySmall(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .displaySmall, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Headline (color)
    static func headlineLarge(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineLarge, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func headlineMedium(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineMedium, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func headlineSmall(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineSmall, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Headline (gradient)
    static func headlineLarge(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineLarge, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func headlineMedium(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineMedium, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func headlineSmall(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .headlineSmall, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Title (color)
    static func titleLarge(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleLarge, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func titleMedium(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleMedium, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func titleSmall(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleSmall, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Title (gradient)
    static func titleLarge(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleLarge, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func titleMedium(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleMedium, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func titleSmall(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .titleSmall, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Body (color)
    static func bodyLarge(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodyLarge, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func bodyMedium(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodyMedium, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func bodySmall(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodySmall, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Body (gradient)
    static func bodyLarge(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodyLarge, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func bodyMedium(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodyMedium, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func bodySmall(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .bodySmall, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Label (color)
    static func labelLarge(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelLarge, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func labelMedium(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelMedium, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func labelSmall(
        _ text: String,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelSmall, color: color, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    // MARK: Label (gradient)
    static func labelLarge(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelLarge, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func labelMedium(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelMedium, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }

    static func labelSmall(
        _ text: String,
        gradient: LinearGradient,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        truncationMode: Text.TruncationMode = .tail,
        fontWeight: Font.Weight? = nil
    ) -> DSText {
        DSText(text, style: .labelSmall, gradient: gradient, alignment: alignment, lineLimit: lineLimit, truncationMode: truncationMode, fontWeight: fontWeight)
    }
}


// MARK: - Preview

#if DEBUG
public struct DSTextPreview: View {
    private var jarvisGradient: LinearGradient {
            LinearGradient(
                colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Display styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Display Styles")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.displayLarge("Display Large")
                    DSText.displayMedium("Display Medium")
                    DSText.displaySmall("Display Small")
                }
                
                Divider()
                
                // Headline styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Headline Styles")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.headlineLarge("Headline Large")
                    DSText.headlineMedium("Headline Medium")
                    DSText.headlineSmall("Headline Small")
                }
                
                Divider()
                
                // Title styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title Styles")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.titleLarge("Title Large")
                    DSText.titleMedium("Title Medium")
                    DSText.titleSmall("Title Small")
                }
                
                Divider()
                
                // Body styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Body Styles")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.bodyLarge("Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    DSText.bodyMedium("Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    DSText.bodySmall("Body Small - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                }
                
                Divider()
                
                // Label styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Label Styles")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.labelLarge("Label Large")
                    DSText.labelMedium("Label Medium")
                    DSText.labelSmall("Label Small")
                }
                
                Divider()
                
                // Color variants
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color Variants")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.titleLarge("Primary Color", color: DSColor.Primary.primary60)
                    DSText.titleLarge("Success Color", color: DSColor.Success.success100)
                    DSText.titleLarge("Warning Color", color: DSColor.Warning.warning100)
                    DSText.titleLarge("Error Color", color: DSColor.Error.error100)
                    DSText.titleLarge("Info Color", color: DSColor.Info.info100)
                }
                
                Divider()
                
                // Alignment variants
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alignment Variants")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.bodyMedium(
                        "Leading alignment text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        alignment: .leading
                    )
                    
                    DSText.bodyMedium(
                        "Center alignment text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        alignment: .center
                    )
                    
                    DSText.bodyMedium(
                        "Trailing alignment text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        alignment: .trailing
                    )
                }
                
                Divider()
                
                // Line limit
                VStack(alignment: .leading, spacing: 12) {
                    Text("Line Limit")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.bodyMedium(
                        "Line limit 2 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        lineLimit: 2
                    )
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("Gradient examples")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.titleLarge("Jarvis Gradient Title", gradient: jarvisGradient)
                    DSText.headlineMedium("Gradient Headline", gradient: jarvisGradient)
                    DSText.bodyMedium("Gradient Body - Lorem ipsum dolor sit amet.", gradient: jarvisGradient)
                    DSText.labelSmall("Gradient Label", gradient: jarvisGradient)
                    
                    Divider()
                    
                    Text("Color examples")
                        .font(.headline)
                        .foregroundColor(DSColor.Neutral.neutral100)
                    
                    DSText.titleLarge("Primary Color", color: DSColor.Primary.primary60)
                    DSText.titleLarge("Success Color", color: DSColor.Success.success100)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("DS Text Component")
    }
}

@available(iOS 17.0, *)
#Preview("DSText Component") {
    NavigationView {
        DSTextPreview()
    }
}

@available(iOS 17.0, *)
#Preview("DSText - Dark Mode") {
    NavigationView {
        DSTextPreview()
    }
    .preferredColorScheme(.dark)
}
#endif
