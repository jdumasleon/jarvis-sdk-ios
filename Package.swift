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
    dependencies: [
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.0.0")
    ],
    targets: [
        // Main SDK
        .target(
            name: "Jarvis",
            dependencies: [
                "JarvisCommon",
                "JarvisData",
                "JarvisDesignSystem",
                "JarvisDomain",
                "JarvisNavigation",
                "JarvisPlatform",
                "JarvisPresentation",
                "JarvisResources",
                "JarvisInspectorDomain",
                "JarvisInspectorPresentation",
                "JarvisPreferencesPresentation"
            ],
            path: "JarvisSDK/Sources/Jarvis"
        ),

        // Core modules (renombrados)
        .target(
            name: "JarvisCommon",
            path: "JarvisSDK/Sources/Core/Common"
        ),
        .target(
            name: "JarvisDomain",
            dependencies: ["JarvisCommon"],
            path: "JarvisSDK/Sources/Core/Domain"
        ),
        .target(
            name: "JarvisData",
            dependencies: [
                "JarvisCommon",
                "JarvisDomain",
                "JarvisPlatform"
            ],
            path: "JarvisSDK/Sources/Core/Data"
        ),
        .target(
            name: "JarvisPlatform",
            dependencies: [
                "JarvisCommon",
                "JarvisDomain",
                .product(name: "PostHog", package: "posthog-ios"),
                .product(name: "Sentry", package: "sentry-cocoa")
            ],
            path: "JarvisSDK/Sources/Core/Platform"
        ),
        .target(
            name: "JarvisNavigation",
            dependencies: ["JarvisCommon"],
            path: "JarvisSDK/Sources/Core/Navigation"
        ),
        .target(
            name: "JarvisPresentation",
            dependencies: [
                "JarvisCommon",
                "JarvisDomain",
                "JarvisDesignSystem",
                "JarvisNavigation",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Core/Presentation"
        ),

        // Inspector
        .target(
            name: "JarvisInspectorDomain",
            dependencies: [
                "JarvisDomain",
                "JarvisCommon"
            ],
            path: "JarvisSDK/Sources/Inspector/Domain"
        ),
        .target(
            name: "JarvisInspectorData",
            dependencies: [
                "JarvisInspectorDomain",
                "JarvisData",
                "JarvisPlatform",
                "JarvisCommon"
            ],
            path: "JarvisSDK/Sources/Inspector/Data"
        ),
        .target(
            name: "JarvisInspectorPresentation",
            dependencies: [
                "JarvisInspectorDomain",
                "JarvisInspectorData",
                "JarvisPresentation",
                "JarvisDesignSystem",
                "JarvisNavigation",
                "JarvisCommon",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Inspector/Presentation"
        ),

        // Preferences
        .target(
            name: "JarvisPreferencesDomain",
            dependencies: [
                "JarvisDomain",
                "JarvisCommon"
            ],
            path: "JarvisSDK/Sources/Preferences/Domain"
        ),
        .target(
            name: "JarvisPreferencesData",
            dependencies: [
                "JarvisPreferencesDomain",
                "JarvisData",
                "JarvisPlatform",
                "JarvisCommon"
            ],
            path: "JarvisSDK/Sources/Preferences/Data"
        ),
        .target(
            name: "JarvisPreferencesPresentation",
            dependencies: [
                "JarvisPreferencesDomain",
                "JarvisPreferencesData",
                "JarvisPresentation",
                "JarvisDesignSystem",
                "JarvisNavigation",
                "JarvisCommon",
                "JarvisResources"
            ],
            path: "JarvisSDK/Sources/Preferences/Presentation"
        ),

        // Resources & DS
        .target(
            name: "JarvisResources",
            path: "JarvisSDK/Sources/Resources",
            resources: [
                .process("Assets.xcassets"),
                .process("JarvisSDKInfo.plist"),
                .process("JarvisInternalConfig.plist")
            ]
        ),
        .target(
            name: "JarvisDesignSystem",
            path: "JarvisSDK/Sources/DesignSystem",
            resources: [
                .process("Resources/Colors.xcassets")
            ]
        ),

        // Tests
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
