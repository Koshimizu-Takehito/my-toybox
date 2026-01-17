// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyToybox",
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
        .package(url: "https://github.com/Koshimizu-Takehito/ScreenMacros", from: "1.0.0"),
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
                .plugin(name: "GenerateScreenID"),
            ]
        ),

        // MARK: - Plugins
        .plugin(
            name: "BuildMetalShaders",
            capability: .buildTool(),
            path: "Plugins/BuildMetalShaders"
        ),
        .plugin(
            name: "GenerateScreenID",
            capability: .buildTool(),
            path: "Plugins/GenerateScreenID"
        ),

        // MARK: - Tests
        .testTarget(
            name: "MyToyboxCoreTests",
            dependencies: ["MyToyboxCore"],
            path: "Tests/MyToyboxCoreTests"
        ),
    ]
)
