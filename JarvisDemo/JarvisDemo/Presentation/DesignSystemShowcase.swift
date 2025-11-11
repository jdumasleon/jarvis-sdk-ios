//
//  DesignSystemShowcase.swift
//  JarvisDemo
//
//  Design System component showcase and preview
//

import SwiftUI
import JarvisDesignSystem

#if DEBUG
struct DesignSystemShowcase: View {
    var body: some View {
        NavigationView {
            List {
                Section("Typography - DSText") {
                    NavigationLink("DSText Examples") {
                        DSTextShowcase()
                    }
                }

                Section("Colors") {
                    NavigationLink("Color Palette") {
                        ColorPaletteShowcase()
                    }
                }

                Section("Components") {
                    NavigationLink("Buttons") {
                        ButtonShowcase()
                    }
                    NavigationLink("Cards") {
                        CardShowcase()
                    }
                }
            }
            .navigationTitle("Design System")
        }
    }
}

// MARK: - DSText Showcase

struct DSTextShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Display styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Display Styles")
                        .font(.headline)

                    DSText.displayLarge("Display Large")
                    DSText.displayMedium("Display Medium")
                    DSText.displaySmall("Display Small")
                }
                .padding()

                Divider()

                // Headline styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Headline Styles")
                        .font(.headline)

                    DSText.headlineLarge("Headline Large")
                    DSText.headlineMedium("Headline Medium")
                    DSText.headlineSmall("Headline Small")
                }
                .padding()

                Divider()

                // Title styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title Styles")
                        .font(.headline)

                    DSText.titleLarge("Title Large")
                    DSText.titleMedium("Title Medium")
                    DSText.titleSmall("Title Small")
                }
                .padding()

                Divider()

                // Body styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Body Styles")
                        .font(.headline)

                    DSText.bodyLarge("Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    DSText.bodyMedium("Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    DSText.bodySmall("Body Small - Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                }
                .padding()

                Divider()

                // Label styles
                VStack(alignment: .leading, spacing: 12) {
                    Text("Label Styles")
                        .font(.headline)

                    DSText.labelLarge("Label Large")
                    DSText.labelMedium("Label Medium")
                    DSText.labelSmall("Label Small")
                }
                .padding()

                Divider()

                // Color variants
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color Variants")
                        .font(.headline)

                    DSText.titleLarge("Primary Color", color: DSColor.Primary.primary60)
                    DSText.titleLarge("Success Color", color: DSColor.Success.success100)
                    DSText.titleLarge("Warning Color", color: DSColor.Warning.warning100)
                    DSText.titleLarge("Error Color", color: DSColor.Error.error100)
                    DSText.titleLarge("Info Color", color: DSColor.Info.info100)
                }
                .padding()

                Divider()

                // Alignment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alignment Options")
                        .font(.headline)

                    DSText.bodyMedium(
                        "Leading alignment text - Lorem ipsum dolor sit amet.",
                        alignment: .leading
                    )

                    DSText.bodyMedium(
                        "Center alignment text - Lorem ipsum dolor sit amet.",
                        alignment: .center
                    )

                    DSText.bodyMedium(
                        "Trailing alignment text - Lorem ipsum dolor sit amet.",
                        alignment: .trailing
                    )
                }
                .padding()

                Divider()

                // Line limit
                VStack(alignment: .leading, spacing: 12) {
                    Text("Line Limit")
                        .font(.headline)

                    DSText.bodyMedium(
                        "Line limit 2 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
                        lineLimit: 2
                    )
                }
                .padding()
            }
        }
        .navigationTitle("DSText Component")
    }
}

// MARK: - Color Palette Showcase

struct ColorPaletteShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                colorSection(title: "Primary", colors: [
                    ("primary100", DSColor.Primary.primary100),
                    ("primary80", DSColor.Primary.primary80),
                    ("primary60", DSColor.Primary.primary60),
                    ("primary40", DSColor.Primary.primary40),
                    ("primary20", DSColor.Primary.primary20),
                    ("primary0", DSColor.Primary.primary0)
                ])

                colorSection(title: "Success", colors: [
                    ("success100", DSColor.Success.success100),
                    ("success80", DSColor.Success.success80),
                    ("success60", DSColor.Success.success60),
                    ("success40", DSColor.Success.success40),
                    ("success20", DSColor.Success.success20)
                ])

                colorSection(title: "Warning", colors: [
                    ("warning100", DSColor.Warning.warning100),
                    ("warning80", DSColor.Warning.warning80),
                    ("warning60", DSColor.Warning.warning60),
                    ("warning40", DSColor.Warning.warning40),
                    ("warning20", DSColor.Warning.warning20)
                ])

                colorSection(title: "Error", colors: [
                    ("error100", DSColor.Error.error100),
                    ("error80", DSColor.Error.error80),
                    ("error60", DSColor.Error.error60),
                    ("error40", DSColor.Error.error40),
                    ("error20", DSColor.Error.error20)
                ])
            }
            .padding()
        }
        .navigationTitle("Colors")
    }

    private func colorSection(title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, item in
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.1)
                            .frame(width: 60, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )

                        Text(item.0)
                            .font(.system(.caption, design: .monospaced))

                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Button Showcase

struct ButtonShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DSButton.primary("Primary Button") { }
                DSButton.secondary("Secondary Button") { }
                DSButton.outline("Outline Button") { }
                DSButton.ghost("Ghost Button") { }
                DSButton.link("Link Button") { }
            }
            .padding()
        }
        .navigationTitle("Buttons")
    }
}

// MARK: - Card Showcase

struct CardShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DSCard(style: .elevated) {
                    DSText.titleMedium("Elevated Card")
                    DSText.bodySmall("This is an elevated card with shadow")
                }

                DSCard(style: .outlined) {
                    DSText.titleMedium("Outlined Card")
                    DSText.bodySmall("This is an outlined card with border")
                }

                DSCard(style: .filled) {
                    DSText.titleMedium("Filled Card")
                    DSText.bodySmall("This is a filled card with background")
                }
            }
            .padding()
        }
        .navigationTitle("Cards")
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview("Design System Showcase") {
    DesignSystemShowcase()
}

@available(iOS 17.0, *)
#Preview("DSText Examples") {
    NavigationView {
        DSTextShowcase()
    }
}

@available(iOS 17.0, *)
#Preview("Color Palette") {
    NavigationView {
        ColorPaletteShowcase()
    }
}
#endif
