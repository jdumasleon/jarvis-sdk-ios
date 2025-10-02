// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisInspector",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "JarvisInspector",
            targets: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "JarvisInspectorPresentation"
            ]
        )
    ],
    dependencies: [
        .package(path: "../JarvisCore")
    ],
    targets: [
        // MARK: - Inspector Feature Modules

        // Inspector Domain: Network inspection business logic
        .target(
            name: "JarvisInspectorDomain",
            dependencies: [
                .product(name: "Domain", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore")
            ],
            path: "Sources/Domain"
        ),

        // Inspector Data: Network interception and data persistence
        .target(
            name: "JarvisInspectorData",
            dependencies: [
                "JarvisInspectorDomain",
                .product(name: "Data", package: "JarvisCore"),
                .product(name: "Platform", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore")
            ],
            path: "Sources/Data"
        ),

        // Inspector Presentation: Network inspector UI and ViewModels
        .target(
            name: "JarvisInspectorPresentation",
            dependencies: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
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
