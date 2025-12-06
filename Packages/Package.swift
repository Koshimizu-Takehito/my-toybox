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
    ],
    targets: [
        // MARK: - MyToyboxCore
        // Note: Utils/Shaders directory is excluded to prevent Xcode from auto-compiling .metal files
        //       .h files are also excluded but remain accessible via #include during plugin compilation
        .target(
            name: "MyToyboxCore",
            dependencies: [],
            path: "Sources/MyToyboxCore",
            exclude: [
                "Utils/Shaders",
            ]
        ),

        // MARK: - MyToyboxScreens
        // Note: Shaders directory is excluded to prevent Xcode from auto-compiling .metal files
        //       They are compiled by BuildMetalShaders plugin instead
        .target(
            name: "MyToyboxScreens",
            dependencies: [
                "MyToyboxCore",
                .product(name: "ScreenMacros", package: "ScreenMacros"),
            ],
            path: "Sources/MyToyboxScreens",
            exclude: [
                "Shaders",
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
