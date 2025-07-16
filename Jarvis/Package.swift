// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Jarvis",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Main Jarvis SDK
        .library(
            name: "Jarvis",
            targets: ["Jarvis"]
        ),
        
        // Core modules
        .library(
            name: "JarvisCore",
            targets: [
                "JarvisCommon",
                "JarvisData", 
                "JarvisDomain",
                "JarvisDesignSystem",
                "JarvisNavigation"
            ]
        ),
        
        // Feature modules
        .library(
            name: "JarvisFeatures",
            targets: [
                "JarvisInspector"
            ]
        )
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        // Main SDK entry point
        .target(
            name: "Jarvis",
            dependencies: [
                "JarvisCommon",
                "JarvisData",
                "JarvisDomain", 
                "JarvisDesignSystem",
                "JarvisNavigation",
                "JarvisInspector"
            ]
        ),
        
        // Core: Common utilities and shared code
        .target(
            name: "JarvisCommon",
            dependencies: []
        ),
        
        // Core: Data layer (repositories, data sources)
        .target(
            name: "JarvisData",
            dependencies: [
                "JarvisCommon",
                "JarvisDomain"
            ]
        ),
        
        // Core: Domain layer (use cases, entities)
        .target(
            name: "JarvisDomain",
            dependencies: [
                "JarvisCommon"
            ]
        ),
        
        // Core: Design system and UI components
        .target(
            name: "JarvisDesignSystem",
            dependencies: [
                "JarvisCommon"
            ]
        ),
        
        // Core: Navigation utilities
        .target(
            name: "JarvisNavigation",
            dependencies: [
                "JarvisCommon"
            ]
        ),
        
        // Features: Inspector for HTTP requests, preferences, etc.
        .target(
            name: "JarvisInspector",
            dependencies: [
                "JarvisCommon",
                "JarvisData",
                "JarvisDomain",
                "JarvisDesignSystem",
                "JarvisNavigation"
            ]
        ),
        
        // Tests
        .testTarget(
            name: "JarvisTests",
            dependencies: ["Jarvis"]
        ),
        .testTarget(
            name: "JarvisCommonTests",
            dependencies: ["JarvisCommon"]
        ),
        .testTarget(
            name: "JarvisDataTests", 
            dependencies: ["JarvisData"]
        ),
        .testTarget(
            name: "JarvisDomainTests",
            dependencies: ["JarvisDomain"]
        ),
        .testTarget(
            name: "JarvisInspectorTests",
            dependencies: ["JarvisInspector"]
        )
    ]
)