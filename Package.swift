// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisSDK",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Main SDK - what external apps will import
        .library(
            name: "Jarvis",
            targets: ["Jarvis"]
        ),

        // Optional: Expose Inspector API separately (if needed)
        .library(
            name: "JarvisInspector",
            targets: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "JarvisInspectorPresentation"
            ]
        ),

        // Optional: Expose Preferences API separately (if needed)
        .library(
            name: "JarvisPreferences",
            targets: [
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                "JarvisPreferencesPresentation"
            ]
        )
    ],
    dependencies: [
        // External dependencies only
    ],
    targets: [
        // MARK: - Main SDK Target
        .target(
            name: "Jarvis",
            dependencies: [
                // Core dependencies
                "Common",
                "Data",
                "DesignSystem",
                "Domain",
                "Navigation",
                "Platform",
                "Presentation",

                // Feature dependencies
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "JarvisInspectorPresentation",
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                "JarvisPreferencesPresentation"
            ],
            path: "Sources/Jarvis"
        ),

        // MARK: - Core Modules
        .target(
            name: "Common",
            dependencies: [],
            path: "Sources/Core/Common"
        ),
        .target(
            name: "Domain",
            dependencies: ["Common"],
            path: "Sources/Core/Domain"
        ),
        .target(
            name: "Data",
            dependencies: [
                "Common",
                "Domain",
                "Platform"
            ],
            path: "Sources/Core/Data"
        ),
        .target(
            name: "Platform",
            dependencies: [
                "Common",
                "Domain"
            ],
            path: "Sources/Core/Platform"
        ),
        .target(
            name: "DesignSystem",
            dependencies: ["Common"],
            path: "Sources/Core/DesignSystem",
            resources: [
                .process("Colors.xcassets")
            ]
        ),
        .target(
            name: "Navigation",
            dependencies: ["Common"],
            path: "Sources/Core/Navigation"
        ),
        .target(
            name: "Presentation",
            dependencies: [
                "Common",
                "Domain",
                "DesignSystem",
                "Navigation"
            ],
            path: "Sources/Core/Presentation"
        ),

        // MARK: - Inspector Feature Modules
        .target(
            name: "JarvisInspectorDomain",
            dependencies: [
                "Domain",
                "Common"
            ],
            path: "Sources/Inspector/Domain"
        ),
        .target(
            name: "JarvisInspectorData",
            dependencies: [
                "JarvisInspectorDomain",
                "Data",
                "Platform",
                "Common"
            ],
            path: "Sources/Inspector/Data"
        ),
        .target(
            name: "JarvisInspectorPresentation",
            dependencies: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "Presentation",
                "DesignSystem",
                "Navigation",
                "Common"
            ],
            path: "Sources/Inspector/Presentation"
        ),

        // MARK: - Preferences Feature Modules
        .target(
            name: "JarvisPreferencesDomain",
            dependencies: [
                "Domain",
                "Common"
            ],
            path: "Sources/Preferences/Domain"
        ),
        .target(
            name: "JarvisPreferencesData",
            dependencies: [
                "JarvisPreferencesDomain",
                "Data",
                "Platform",
                "Common"
            ],
            path: "Sources/Preferences/Data"
        ),
        .target(
            name: "JarvisPreferencesPresentation",
            dependencies: [
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                "Presentation",
                "DesignSystem",
                "Navigation",
                "Common"
            ],
            path: "Sources/Preferences/Presentation"
        )

        // MARK: - Tests
        // Tests will be added later when test structure is established
    ]
)
