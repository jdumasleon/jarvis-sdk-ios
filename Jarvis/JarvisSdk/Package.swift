// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisSdk",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "JarvisSdk",
            targets: ["JarvisSdk"]
        )
    ],
    dependencies: [
        .package(name: "Jarvis", path: "../")
    ],
    targets: [
        .target(
            name: "JarvisSdk",
            dependencies: [
                .product(name: "Jarvis", package: "Jarvis")
            ],
            path: "Sources"
        )
    ]
)
