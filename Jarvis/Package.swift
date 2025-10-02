// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Jarvis",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Main Jarvis SDK
        .library(
            name: "Jarvis",
            targets: ["JarvisSDK"]
        )
    ],
    dependencies: [
        .package(path: "../JarvisCore"),
        .package(path: "../JarvisInspector"),
        .package(path: "../JarvisPreferences")
    ],
    targets: [
        // Main SDK entry point with internal features
        .target(
            name: "JarvisSDK",
            dependencies: [
                // Core dependencies
                .product(name: "DesignSystem", package: "JarvisCore"),
                .product(name: "Common", package: "JarvisCore"),
                .product(name: "Domain", package: "JarvisCore"),
                .product(name: "Data", package: "JarvisCore"),
                .product(name: "Platform", package: "JarvisCore"),
                .product(name: "Presentation", package: "JarvisCore"),
                .product(name: "Navigation", package: "JarvisCore"),

                // Optional feature dependencies
                .product(name: "JarvisInspector", package: "JarvisInspector"),
                .product(name: "JarvisPreferences", package: "JarvisPreferences")
            ],
            path: "Sources"
        )
    ]
)
