import SwiftUI

/// Design System Colors
/// All colors automatically adapt to light/dark themes via Colors.xcassets
public struct DSColor {

    // MARK: - Primary Colors
    public struct Primary {
        public static let primary100 = Color("Primary100")
        public static let primary80 = Color("Primary80")
        public static let primary60 = Color("Primary60") // Main brand color
        public static let primary40 = Color("Primary40")
        public static let primary20 = Color("Primary20")
        public static let primary0 = Color("Primary0")
    }

    // MARK: - Secondary Colors
    public struct Secondary {
        public static let secondary100 = Color("Secondary100")
        public static let secondary80 = Color("Secondary80")
        public static let secondary60 = Color("Secondary60")
        public static let secondary40 = Color("Secondary40")
        public static let secondary20 = Color("Secondary20")
    }

    // MARK: - Neutral Colors
    public struct Neutral {
        public static let neutral100 = Color("Neutral100")
        public static let neutral80 = Color("Neutral80")
        public static let neutral60 = Color("Neutral60")
        public static let neutral40 = Color("Neutral40")
        public static let neutral300 = neutral40 // Legacy compatibility
        public static let neutral500 = neutral60 // Legacy compatibility
        public static let neutral50 = neutral20 // Legacy compatibility
        public static let neutral20 = Color("Neutral20")
        public static let neutral0 = Color("Neutral0")
    }

    // MARK: - Semantic Colors
    public struct Success {
        public static let success100 = Color("Success100")
        public static let success80 = Color("Success80")
        public static let success60 = Color("Success60")
        public static let success40 = Color("Success40")
        public static let success20 = Color("Success20")
    }

    public struct Warning {
        public static let warning100 = Color("Warning100")
        public static let warning80 = Color("Warning80")
        public static let warning60 = Color("Warning60")
        public static let warning40 = Color("Warning40")
        public static let warning20 = Color("Warning20")
    }

    public struct Error {
        public static let error100 = Color("Error100")
        public static let error80 = Color("Error80")
        public static let error60 = Color("Error60")
        public static let error40 = Color("Error40")
        public static let error20 = Color("Error20")
    }

    public struct Info {
        public static let info100 = Color("Info100")
        public static let info80 = Color("Info80")
        public static let info60 = Color("Info60")
        public static let info40 = Color("Info40")
        public static let info20 = Color("Info20")
    }

    // MARK: - Extra Colors (Jarvis Brand & Utility)
    public struct Extra {
        // Brand colors
        public static let jarvisPink = Color("JarvisPink")
        public static let jarvisBlue = Color("JarvisBlue")

        // Background colors
        public static let background0 = Color("Background0")

        // Utility colors
        public static let white = Color("White")
        public static let black = Color("Black")
        public static let transparent = Color("Clear")

        // Surface colors
        public static let surface = white
        public static let onSurface = Neutral.neutral100
    }

    // MARK: - Chart Colors
    public struct Chart {
        public static let blue = Color("ChartBlue")
        public static let green = Color("ChartGreen")
        public static let orange = Color("ChartOrange")
        public static let purple = Color("ChartPurple")
        public static let red = Color("ChartRed")
        public static let cyan = Color("ChartCyan")
        public static let yellow = Color("ChartYellow")
        public static let blueGrey = Color("ChartBlueGrey")
        public static let pink = Color("ChartPink")
        public static let brown = Color("ChartBrown")

        public static let colors = [
            blue, green, orange, purple, red,
            cyan, yellow, blueGrey, pink, brown
        ]
    }
    
    // MARK: - Surface Colors
    public struct Surface {
        public static let background = Extra.background0
        public static let backgroundSecondary = Neutral.neutral0
        public static let surface = Extra.white
        public static let surfaceElevated = Extra.white
        public static let surfaceOverlay = Extra.black.opacity(0.5)
        public static let border = Neutral.neutral20
        public static let borderSubtle = Neutral.neutral0
        public static let divider = Neutral.neutral20
    }

    // MARK: - Text Colors
    public struct Text {
        public static let primary = Neutral.neutral100
        public static let secondary = Neutral.neutral80
        public static let tertiary = Neutral.neutral60
        public static let disabled = Neutral.neutral40
        public static let inverse = Extra.black
        public static let onPrimary = Extra.white
        public static let onSecondary = Extra.white
        public static let link = Primary.primary60
        public static let linkHover = Primary.primary80
    }

    // MARK: - Interactive Colors
    public struct Interactive {
        public static let primary = Primary.primary60
        public static let primaryHover = Primary.primary80
        public static let primaryPressed = Primary.primary100
        public static let primaryDisabled = Neutral.neutral40
        public static let secondary = Secondary.secondary100
        public static let secondaryHover = Secondary.secondary80
        public static let secondaryPressed = Secondary.secondary60
        public static let secondaryDisabled = Neutral.neutral40
        public static let ghost = Extra.transparent
        public static let ghostHover = Neutral.neutral0
        public static let ghostPressed = Neutral.neutral20
    }

    // MARK: - Status Colors
    public struct Status {
        public static let online = Success.success100
        public static let offline = Neutral.neutral60
        public static let busy = Warning.warning100
        public static let away = Warning.warning60
        public static let dnd = Error.error100
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
