// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisPreferences",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
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
        .package(path: "../JarvisCore")
    ],
    targets: [
        // MARK: - Preferences Feature Modules

        // Preferences Domain: Preferences monitoring business logic
        .target(
            name: "JarvisPreferencesDomain",
            dependencies: [
                .product(name: "Domain", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore")
            ],
            path: "Sources/Domain"
        ),

        // Preferences Data: Preferences monitoring and data persistence
        .target(
            name: "JarvisPreferencesData",
            dependencies: [
                "JarvisPreferencesDomain",
                .product(name: "Data", package: "JarvisCore"),
                .product(name: "Platform", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore")
            ],
            path: "Sources/Data"
        ),

        // Preferences Presentation: Preferences inspector UI and ViewModels
        .target(
            name: "JarvisPreferencesPresentation",
            dependencies: [
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                .product(name: "Presentation", package: "JarvisCore"),
                .product(name: "DesignSystem", package: "JarvisCore"),
                .product(name: "Navigation", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore")
            ],
            path: "Sources/Presentation"
        )

        // MARK: - Tests
        // Tests will be added later when test structure is established
    ]
)
