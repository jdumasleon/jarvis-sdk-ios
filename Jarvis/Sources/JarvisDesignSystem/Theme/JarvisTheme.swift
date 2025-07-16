import SwiftUI

public struct JarvisTheme {
    public static let primary = Color(red: 0.2, green: 0.6, blue: 1.0)
    public static let secondary = Color(red: 0.5, green: 0.5, blue: 0.5)
    public static let success = Color(red: 0.2, green: 0.8, blue: 0.2)
    public static let warning = Color(red: 1.0, green: 0.8, blue: 0.0)
    public static let error = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    public static let background = Color(UIColor.systemBackground)
    public static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    public static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    public static let text = Color(UIColor.label)
    public static let secondaryText = Color(UIColor.secondaryLabel)
    public static let tertiaryText = Color(UIColor.tertiaryLabel)
    
    public static let border = Color(UIColor.separator)
    public static let shadow = Color.black.opacity(0.1)
}

public extension Color {
    static let jarvis = JarvisTheme.self
}

public struct JarvisSpacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}

public struct JarvisCornerRadius {
    public static let sm: CGFloat = 4
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 12
    public static let xl: CGFloat = 16
}

public struct JarvisFont {
    public static let caption = Font.caption
    public static let footnote = Font.footnote
    public static let body = Font.body
    public static let subheadline = Font.subheadline
    public static let headline = Font.headline
    public static let title3 = Font.title3
    public static let title2 = Font.title2
    public static let title = Font.title
    public static let largeTitle = Font.largeTitle
    
    public static let codeMono = Font.system(.body, design: .monospaced)
    public static let codeMonoSmall = Font.system(.caption, design: .monospaced)
}