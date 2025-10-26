// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisDesignSystem",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        )
    ],
    dependencies: [
        // No external dependencies - design system should be standalone
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [],
            path: "Sources/DesignSystem",
            resources: [
                .process("Resources/Colors.xcassets")
            ]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        )
    ]
)
