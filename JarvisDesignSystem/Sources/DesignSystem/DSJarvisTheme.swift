import SwiftUI

// Import all foundation types to ensure they're available when this module is imported
// This ensures external packages can access these types without explicit individual imports

// MARK: - Main Design System Export

/// Jarvis Design System
///
/// A comprehensive design system for the Jarvis iOS SDK providing:
/// - Foundation elements (Colors, Typography, Spacing, Icons)
/// - UI Components (Buttons, Cards, Forms, Navigation, etc.)
/// - Consistent styling and theming across the entire SDK
///
/// Usage:
/// ```swift
/// import DesignSystem
///
/// // Use foundation elements
/// Text("Hello")
///     .dsTextStyle(.titleMedium)
///     .foregroundColor(DSColor.Neutral.neutral100)
///     .dsPadding(DSSpacing.m)
///
/// // Use components
/// DSButton.primary("Save") {
///     // action
/// }
/// ```
public struct DSJarvisTheme {

    // MARK: - Foundation
    /// Color palette and semantic colors
    public static let color = DSColor.self

    /// Typography scales and text styles
    public static let typography = DSTypography.self

    /// Spacing, layout, and sizing values
    public static let spacing = DSSpacing.self

    /// Border radius values
    public static let radius = DSRadius.self

    /// Border width values
    public static let borderWidth = DSBorderWidth.self

    /// Elevation and shadow styles
    public static let elevation = DSElevation.self

    /// Icon size values
    public static let iconSize = DSIconSize.self

    /// Icon library
    public static let icons = DSIcons.self

    /// Layout constants and breakpoints
    public static let layout = DSLayout.self

    // MARK: - Text Styles
    /// Pre-configured text styles with proper typography, line height, and spacing
    public static let textStyle = DSTextStyle.self

    // MARK: - Version
    /// Design system version
    public static let version = "1.0.0"
}

// MARK: - Design System Components

// All components are exported directly from their respective files
// No need for typealiases as they would create circular references

// MARK: - Convenience Extensions

public extension View {
    /// Apply Jarvis design system styling
    func jarvisStyle() -> some View {
        self
            .background(DSColor.Extra.background0)
            .foregroundColor(DSColor.Neutral.neutral100)
    }

    /// Apply container styling with proper padding and background
    func jarvisContainer() -> some View {
        self
            .dsContainerPadding()
            .background(DSColor.Extra.background0)
            .foregroundColor(DSColor.Neutral.neutral100)
    }

    /// Apply card-like styling
    func jarvisCard(style: DSCard<AnyView>.Style = .elevated) -> some View {
        DSCard(style: style) {
            AnyView(self)
        }
    }

    /// Apply standard section spacing
    func jarvisSectionSpacing() -> some View {
        self.dsPadding(.vertical, DSLayout.sectionSpacing)
    }
}

// MARK: - Theme Support

/// Theme configuration for the design system
public struct DSTheme {
    public let colors: DSColorScheme
    public let typography: DSTypographyScheme
    public let spacing: DSSpacingScheme

    public init(
        colors: DSColorScheme = .default,
        typography: DSTypographyScheme = .default,
        spacing: DSSpacingScheme = .default
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
    }

    public static let `default` = DSTheme()
}

/// Color scheme configuration
public struct DSColorScheme {
    // This can be extended in the future to support different color schemes
    public static let `default` = DSColorScheme()
}

/// Typography scheme configuration
public struct DSTypographyScheme {
    // This can be extended in the future to support different typography schemes
    public static let `default` = DSTypographyScheme()
}

/// Spacing scheme configuration
public struct DSSpacingScheme {
    // This can be extended in the future to support different spacing schemes
    public static let `default` = DSSpacingScheme()
}

// MARK: - Design System Environment

/// Environment key for design system theme
private struct DSThemeKey: EnvironmentKey {
    static let defaultValue = DSTheme.default
}

public extension EnvironmentValues {
    var dsTheme: DSTheme {
        get { self[DSThemeKey.self] }
        set { self[DSThemeKey.self] = newValue }
    }
}

public extension View {
    /// Apply a design system theme to the view hierarchy
    func dsTheme(_ theme: DSTheme) -> some View {
        environment(\.dsTheme, theme)
    }
}

// MARK: - Preview Support

#if DEBUG
/// Preview helper for testing design system components
public struct DSPreviewContainer<Content: View>: View {
    private let content: Content
    private let theme: DSTheme

    public init(
        theme: DSTheme = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        content
            .dsTheme(theme)
            .background(DSColor.Extra.background0)
            .preferredColorScheme(.light)
    }
}

/// Comprehensive design system showcase
public struct DSShowcase: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List {
                NavigationLink("Foundation", destination: DSFoundationShowcase())
                NavigationLink("Buttons", destination: DSButtonPreview())
                NavigationLink("Cards", destination: DSCardPreview())
                NavigationLink("Text Fields", destination: DSTextFieldPreview())
                NavigationLink("Alerts & Modals", destination: DSAlertPreview())
                NavigationLink("Lists & Data", destination: DSListPreview())
                NavigationLink("Navigation", destination: DSNavigationPreview())
                NavigationLink("Floating Action Buttons", destination: DSFloatingActionButtonPreview())
            }
            .navigationTitle("Design System")
        }
    }
}

/// Foundation elements showcase
public struct DSFoundationShowcase: View {
    public var body: some View {
        List {
            NavigationLink("Colors", destination: Text("Colors Preview")) // DSColorPreview() would go here
            NavigationLink("Typography", destination: DSTypographyPreview())
            NavigationLink("Spacing & Layout", destination: DSSpacingPreview())
            NavigationLink("Icons", destination: DSIconsPreview())
        }
        .navigationTitle("Foundation")
    }
}

@available(iOS 17.0, *)
#Preview("Design System Showcase") {
    DSPreviewContainer {
        DSShowcase()
    }
}
#endif
