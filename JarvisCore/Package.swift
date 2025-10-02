// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Core package product
        .library(
            name: "JarvisCore",
            targets: [
                "Common",
                "Data",
                "DesignSystem",
                "Domain",
                "Navigation",
                "Platform",
                "Presentation"
            ]
        ),

        // Individual module products
        .library(name: "Common", targets: ["Common"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Navigation", targets: ["Navigation"]),
        .library(name: "Platform", targets: ["Platform"]),
        .library(name: "Presentation", targets: ["Presentation"])
    ],
    dependencies: [
        // External dependencies can be added here
    ],
    targets: [
        // MARK: - Core Modules

        // Common: Shared utilities, extensions, and foundation code
        .target(
            name: "Common",
            dependencies: [],
            path: "Sources/Common"
        ),

        // Domain: Business logic, entities, and use cases
        .target(
            name: "Domain",
            dependencies: [
                "Common"
            ],
            path: "Sources/Domain"
        ),

        // Data: Repositories, data sources, and storage
        .target(
            name: "Data",
            dependencies: [
                "Common",
                "Domain",
                "Platform"
            ],
            path: "Sources/Data"
        ),

        // Platform: iOS-specific implementations and platform abstractions
        .target(
            name: "Platform",
            dependencies: [
                "Common",
                "Domain"
            ],
            path: "Sources/Platform"
        ),

        // Design System: UI components, themes, and styling
        .target(
            name: "DesignSystem",
            dependencies: [
                "Common"
            ],
            path: "Sources/DesignSystem",
            resources: [
                .process("Colors.xcassets")
            ]
        ),

        // Navigation: Navigation logic and routing
        .target(
            name: "Navigation",
            dependencies: [
                "Common"
            ],
            path: "Sources/Navigation"
        ),

        // Presentation: Common presentation logic, ViewModels base classes
        .target(
            name: "Presentation",
            dependencies: [
                "Common",
                "Domain",
                "DesignSystem",
                "Navigation"
            ],
            path: "Sources/Presentation"
        )

        // MARK: - Tests
        // Tests will be added later when test structure is established
    ]
)
