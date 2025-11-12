// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Jarvis",
            targets: ["Jarvis"]
        ),
        .library(
            name: "JarvisDesignSystem",
            targets: ["JarvisDesignSystem"]
        )
    ],
    dependencies: [],
    targets: [
        // MARK: - Main SDK Target
        .target(
            name: "Jarvis",
            dependencies: [
                "Common",
                "Data",
                "JarvisDesignSystem",
                "Domain",
                "Navigation",
                "Platform",
                "Presentation",
                "JarvisResources",
                "JarvisInspectorPresentation",
                "JarvisPreferencesPresentation"
            ],
            path: "JarvisSDK/Sources/Jarvis"
        ),

        // MARK: - Core Modules
        .target(
            name: "Common",
            dependencies: [],
            path: "JarvisSDK/Sources/Core/Common"
        ),
        .target(
            name: "Domain",
            dependencies: ["Common"],
            path: "JarvisSDK/Sources/Core/Domain"
        ),
        .target(
            name: "Data",
            dependencies: [
                "Common",
                "Domain",
                "Platform"
            ],
            path: "JarvisSDK/Sources/Core/Data"
        ),
        .target(
            name: "Platform",
            dependencies: [
                "Common",
                "Domain"
            ],
            path: "JarvisSDK/Sources/Core/Platform"
        ),
        .target(
            name: "Navigation",
            dependencies: ["Common"],
            path: "JarvisSDK/Sources/Core/Navigation"
        ),
        .target(
            name: "Presentation",
            dependencies: [
                "Common",
                "Domain",
                "JarvisDesignSystem",
                "Navigation",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Core/Presentation"
        ),

        // MARK: - Inspector Feature Modules
        .target(
            name: "JarvisInspectorDomain",
            dependencies: [
                "Domain",
                "Common"
            ],
            path: "JarvisSDK/Sources/Inspector/Domain"
        ),
        .target(
            name: "JarvisInspectorData",
            dependencies: [
                "JarvisInspectorDomain",
                "Data",
                "Platform",
                "Common"
            ],
            path: "JarvisSDK/Sources/Inspector/Data"
        ),
        .target(
            name: "JarvisInspectorPresentation",
            dependencies: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "Presentation",
                "JarvisDesignSystem",
                "Navigation",
                "Common",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Inspector/Presentation"
        ),

        // MARK: - Preferences Feature Modules
        .target(
            name: "JarvisPreferencesDomain",
            dependencies: [
                "Domain",
                "Common"
            ],
            path: "JarvisSDK/Sources/Preferences/Domain"
        ),
        .target(
            name: "JarvisPreferencesData",
            dependencies: [
                "JarvisPreferencesDomain",
                "Data",
                "Platform",
                "Common"
            ],
            path: "JarvisSDK/Sources/Preferences/Data"
        ),
        .target(
            name: "JarvisPreferencesPresentation",
            dependencies: [
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                "Presentation",
                "JarvisDesignSystem",
                "Navigation",
                "Common",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Preferences/Presentation"
        ),
        .target(
            name: "JarvisResources",
            path: "JarvisSDK/Sources/Resources",
            resources: [
                .process("Assets.xcassets"),
                .process("JarvisSDKInfo.plist")
            ]
        ),
        .target(
            name: "JarvisDesignSystem",
            dependencies: [],
            path: "JarvisSDK/Sources/DesignSystem",
            resources: [
                .process("Resources/Colors.xcassets")
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "JarvisSDKTests",
            dependencies: [
                "Jarvis",
                "JarvisInspectorData"
            ],
            path: "JarvisSDK/Tests/JarvisSDKTests"
        )
    ]
)

