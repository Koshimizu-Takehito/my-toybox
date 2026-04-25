// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyToybox",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "MyToyboxCore",
            targets: ["MyToyboxCore"]
        ),
        .library(
            name: "MyToyboxScreens",
            targets: ["MyToyboxScreens"]
        ),
    ],
    dependencies: [
        .package(path: "../ScreenMacros"),
        .package(path: "../MetadatasMacros"),
    ],
    targets: [
        // MARK: - MyToyboxCore
        .target(
            name: "MyToyboxCore",
            dependencies: [],
            path: "Sources/MyToyboxCore"
        ),

        // MARK: - MyToyboxScreens
        // Note: Utils/Shaders directory is excluded to prevent Xcode from auto-compiling .metal files
        //       They are compiled by BuildMetalShaders plugin instead
        .target(
            name: "MyToyboxScreens",
            dependencies: [
                "MyToyboxCore",
                .target(name: "MyToyboxScreensUIKit", condition: .when(platforms: [.iOS])),
                .product(name: "MetadatasMacros", package: "MetadatasMacros"),
                .product(name: "ScreenMacros", package: "ScreenMacros"),
            ],
            path: "Sources/MyToyboxScreens",
            exclude: [
                "Shaders",
                "Utils/Shaders",
            ],
            resources: [
                .process("Resources"),
            ],
            plugins: [
                .plugin(name: "BuildMetalShaders"),
            ]
        ),

        // MARK: - iOS-only UIKit resources
        .target(
            name: "MyToyboxScreensUIKit",
            dependencies: [],
            path: "Sources/MyToyboxScreensUIKit",
            resources: [
                .process("Resources"),
            ]
        ),

        // MARK: - Plugins
        .plugin(
            name: "BuildMetalShaders",
            capability: .buildTool(),
            path: "Plugins/BuildMetalShaders"
        ),

        // MARK: - Tests
        .testTarget(
            name: "MyToyboxCoreTests",
            dependencies: ["MyToyboxCore"],
            path: "Tests/MyToyboxCoreTests"
        ),
    ]
)
