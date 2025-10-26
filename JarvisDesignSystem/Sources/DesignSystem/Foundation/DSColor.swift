import SwiftUI

/// Design System Colors
/// All colors automatically adapt to light/dark themes via Colors.xcassets
public struct DSColor {

    // MARK: - Primary Colors
    public struct Primary {
        public static let primary100 = Color("Primary100", bundle: .module)
        public static let primary80 = Color("Primary80", bundle: .module)
        public static let primary60 = Color("Primary60", bundle: .module) // Main brand color
        public static let primary40 = Color("Primary40", bundle: .module)
        public static let primary20 = Color("Primary20", bundle: .module)
        public static let primary0 = Color("Primary0", bundle: .module)
    }

    // MARK: - Secondary Colors
    public struct Secondary {
        public static let secondary100 = Color("Secondary100", bundle: .module)
        public static let secondary80 = Color("Secondary80", bundle: .module)
        public static let secondary60 = Color("Secondary60", bundle: .module)
        public static let secondary40 = Color("Secondary40", bundle: .module)
        public static let secondary20 = Color("Secondary20", bundle: .module)
    }

    // MARK: - Neutral Colors
    public struct Neutral {
        public static let neutral100 = Color("Neutral100", bundle: .module)
        public static let neutral80 = Color("Neutral80", bundle: .module)
        public static let neutral60 = Color("Neutral60", bundle: .module)
        public static let neutral40 = Color("Neutral40", bundle: .module)
        public static let neutral20 = Color("Neutral20", bundle: .module)
        public static let neutral0 = Color("Neutral0", bundle: .module)
    }

    // MARK: - Semantic Colors
    public struct Success {
        public static let success100 = Color("Success100", bundle: .module)
        public static let success80 = Color("Success80", bundle: .module)
        public static let success60 = Color("Success60", bundle: .module)
        public static let success40 = Color("Success40", bundle: .module)
        public static let success20 = Color("Success20", bundle: .module)
    }

    public struct Warning {
        public static let warning100 = Color("Warning100", bundle: .module)
        public static let warning80 = Color("Warning80", bundle: .module)
        public static let warning60 = Color("Warning60", bundle: .module)
        public static let warning40 = Color("Warning40", bundle: .module)
        public static let warning20 = Color("Warning20", bundle: .module)
    }

    public struct Error {
        public static let error100 = Color("Error100", bundle: .module)
        public static let error80 = Color("Error80", bundle: .module)
        public static let error60 = Color("Error60", bundle: .module)
        public static let error40 = Color("Error40", bundle: .module)
        public static let error20 = Color("Error20", bundle: .module)
    }

    public struct Info {
        public static let info100 = Color("Info100", bundle: .module)
        public static let info80 = Color("Info80", bundle: .module)
        public static let info60 = Color("Info60", bundle: .module)
        public static let info40 = Color("Info40", bundle: .module)
        public static let info20 = Color("Info20", bundle: .module)
    }

    // MARK: - Extra Colors (Jarvis Brand & Utility)
    public struct Extra {
        // Brand colors
        public static let jarvisPink = Color("JarvisPink", bundle: .module)
        public static let jarvisBlue = Color("JarvisBlue", bundle: .module)

        // Background colors
        public static let background0 = Color("Background0", bundle: .module)

        // Utility colors
        public static let white = Color("White", bundle: .module)
        public static let black = Color("Black", bundle: .module)
        public static let transparent = Color("Clear", bundle: .module)

        // Surface colors
        public static let surface = white
        public static let onSurface = Neutral.neutral100
    }

    // MARK: - Chart Colors
    public struct Chart {
        public static let blue = Color("ChartBlue", bundle: .module)
        public static let green = Color("ChartGreen", bundle: .module)
        public static let orange = Color("ChartOrange", bundle: .module)
        public static let purple = Color("ChartPurple", bundle: .module)
        public static let red = Color("ChartRed", bundle: .module)
        public static let cyan = Color("ChartCyan", bundle: .module)
        public static let yellow = Color("ChartYellow", bundle: .module)
        public static let blueGrey = Color("ChartBlueGrey", bundle: .module)
        public static let pink = Color("ChartPink", bundle: .module)
        public static let brown = Color("ChartBrown", bundle: .module)

        public static let colors = [
            blue, green, orange, purple, red,
            cyan, yellow, blueGrey, pink, brown
        ]
    }
}

// MARK: - Color Extensions
public extension Color {
    /// Create a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSColorPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Primary Colors
                ColorPaletteSection(
                    title: "Primary Colors",
                    subtitle: "Brand identity colors",
                    colors: [
                        ("primary100", DSColor.Primary.primary100),
                        ("primary80", DSColor.Primary.primary80),
                        ("primary60", DSColor.Primary.primary60),
                        ("primary40", DSColor.Primary.primary40),
                        ("primary20", DSColor.Primary.primary20),
                        ("primary0", DSColor.Primary.primary0)
                    ]
                )

                Divider()

                // Secondary Colors
                ColorPaletteSection(
                    title: "Secondary Colors",
                    subtitle: "Supporting brand colors",
                    colors: [
                        ("secondary100", DSColor.Secondary.secondary100),
                        ("secondary80", DSColor.Secondary.secondary80),
                        ("secondary60", DSColor.Secondary.secondary60),
                        ("secondary40", DSColor.Secondary.secondary40),
                        ("secondary20", DSColor.Secondary.secondary20)
                    ]
                )

                Divider()

                // Neutral Colors
                ColorPaletteSection(
                    title: "Neutral Colors",
                    subtitle: "Grayscale for text and backgrounds",
                    colors: [
                        ("neutral100", DSColor.Neutral.neutral100),
                        ("neutral80", DSColor.Neutral.neutral80),
                        ("neutral60", DSColor.Neutral.neutral60),
                        ("neutral40", DSColor.Neutral.neutral40),
                        ("neutral20", DSColor.Neutral.neutral20),
                        ("neutral0", DSColor.Neutral.neutral0)
                    ]
                )

                Divider()

                // Success Colors
                ColorPaletteSection(
                    title: "Success Colors",
                    subtitle: "Positive feedback and success states",
                    colors: [
                        ("success100", DSColor.Success.success100),
                        ("success80", DSColor.Success.success80),
                        ("success60", DSColor.Success.success60),
                        ("success40", DSColor.Success.success40),
                        ("success20", DSColor.Success.success20)
                    ]
                )

                Divider()

                // Warning Colors
                ColorPaletteSection(
                    title: "Warning Colors",
                    subtitle: "Caution and warning states",
                    colors: [
                        ("warning100", DSColor.Warning.warning100),
                        ("warning80", DSColor.Warning.warning80),
                        ("warning60", DSColor.Warning.warning60),
                        ("warning40", DSColor.Warning.warning40),
                        ("warning20", DSColor.Warning.warning20)
                    ]
                )

                Divider()

                // Error Colors
                ColorPaletteSection(
                    title: "Error Colors",
                    subtitle: "Errors and destructive actions",
                    colors: [
                        ("error100", DSColor.Error.error100),
                        ("error80", DSColor.Error.error80),
                        ("error60", DSColor.Error.error60),
                        ("error40", DSColor.Error.error40),
                        ("error20", DSColor.Error.error20)
                    ]
                )

                Divider()

                // Info Colors
                ColorPaletteSection(
                    title: "Info Colors",
                    subtitle: "Informational messages",
                    colors: [
                        ("info100", DSColor.Info.info100),
                        ("info80", DSColor.Info.info80),
                        ("info60", DSColor.Info.info60),
                        ("info40", DSColor.Info.info40),
                        ("info20", DSColor.Info.info20)
                    ]
                )

                Divider()

                // Extra Colors
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Extra Colors")
                            .font(.headline)
                        Text("Brand specific and utility colors")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 8) {
                        ColorSwatchRow(name: "jarvisPink", color: DSColor.Extra.jarvisPink)
                        ColorSwatchRow(name: "jarvisBlue", color: DSColor.Extra.jarvisBlue)
                        ColorSwatchRow(name: "background0", color: DSColor.Extra.background0)
                        ColorSwatchRow(name: "white", color: DSColor.Extra.white)
                        ColorSwatchRow(name: "black", color: DSColor.Extra.black)
                    }
                }

                Divider()

                // Chart Colors
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chart Colors")
                            .font(.headline)
                        Text("Data visualization colors")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ColorSwatchCard(name: "blue", color: DSColor.Chart.blue)
                        ColorSwatchCard(name: "green", color: DSColor.Chart.green)
                        ColorSwatchCard(name: "orange", color: DSColor.Chart.orange)
                        ColorSwatchCard(name: "purple", color: DSColor.Chart.purple)
                        ColorSwatchCard(name: "red", color: DSColor.Chart.red)
                        ColorSwatchCard(name: "cyan", color: DSColor.Chart.cyan)
                        ColorSwatchCard(name: "yellow", color: DSColor.Chart.yellow)
                        ColorSwatchCard(name: "blueGrey", color: DSColor.Chart.blueGrey)
                        ColorSwatchCard(name: "pink", color: DSColor.Chart.pink)
                        ColorSwatchCard(name: "brown", color: DSColor.Chart.brown)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Color System")
    }
}

// MARK: - Helper Views

private struct ColorPaletteSection: View {
    let title: String
    let subtitle: String
    let colors: [(String, Color)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(DSColor.Neutral.neutral100)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(DSColor.Neutral.neutral80)
            }

            VStack(spacing: 8) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, item in
                    ColorSwatchRow(name: item.0, color: item.1)
                }
            }
        }
    }
}

private struct ColorSwatchRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(DSColor.Extra.black)
                Text("DSColor.\(categoryForColor(name)).\(name)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(DSColor.Neutral.neutral60)
            }

            Spacer()
        }
        .padding(8)
        .background(DSColor.Extra.white)
        .cornerRadius(8)
    }

    private func categoryForColor(_ name: String) -> String {
        if name.hasPrefix("primary") { return "Primary" }
        if name.hasPrefix("secondary") { return "Secondary" }
        if name.hasPrefix("neutral") { return "Neutral" }
        if name.hasPrefix("success") { return "Success" }
        if name.hasPrefix("warning") { return "Warning" }
        if name.hasPrefix("error") { return "Error" }
        if name.hasPrefix("info") { return "Info" }
        return "Extra"
    }
}

private struct ColorSwatchCard: View {
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(DSColor.Extra.white)
        .cornerRadius(8)
    }
}

@available(iOS 17.0, *)
#Preview("Color System - Light Mode") {
    NavigationView {
        DSColorPreview()
    }
}

@available(iOS 17.0, *)
#Preview("Color System - Dark Mode") {
    NavigationView {
        DSColorPreview()
    }
    .preferredColorScheme(.dark)
}
#endif
