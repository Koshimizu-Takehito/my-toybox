// swift-tools-version: 6.1
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
            name: "ClipScreens",
            targets: ["ClipScreens"]
        ),
        .library(
            name: "TagPicker",
            targets: ["TagPicker"]
        ),
        .library(
            name: "AppScreens",
            targets: ["AppScreens"]
        ),
        .library(
            name: "PlatformSupport",
            targets: ["PlatformSupport"]
        ),
        .library(
            name: "DetailScreen",
            targets: ["DetailScreen"]
        ),
        .library(
            name: "RootScreen",
            targets: ["RootScreen"]
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
            dependencies: [
                .product(name: "MetadatasMacros", package: "MetadatasMacros"),
            ],
            path: "Sources/MyToyboxCore"
        ),

        // MARK: - MyToyboxMedia
        .target(
            name: "MyToyboxMedia",
            path: "Sources/MyToyboxMedia",
            resources: [.process("Resources")]
        ),

        // MARK: - PlatformSupport
        .target(
            name: "PlatformSupport",
            path: "Sources/PlatformSupport"
        ),

        // MARK: - DetailScreen
        .target(
            name: "DetailScreen",
            dependencies: [
                "MyToyboxCore",
                "MockScreens",
            ],
            path: "Sources/Screens/DetailScreen",
            resources: [.process("Resources")]
        ),

        // MARK: - RootScreen
        .target(
            name: "RootScreen",
            dependencies: [
                "MyToyboxCore",
                "DetailScreen",
                "MockScreens",
            ],
            path: "Sources/Screens/RootScreen",
            resources: [.process("Resources")]
        ),

        // MARK: - MockScreens
        .target(
            name: "MockScreens",
            dependencies: [
                "MyToyboxCore",
                .product(name: "MetadatasMacros", package: "MetadatasMacros"),
                .product(name: "ScreenMacros", package: "ScreenMacros"),
            ],
            path: "Sources/MockScreens"
        ),

        // MARK: - Screen Modules
        .target(
            name: "Screen_Badge",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Badge",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_DotsSpinner",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/DotsSpinner",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_RingSlider",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/RingSlider",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_CircleSDF2",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/CircleSDF2",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_VoronoiDiagram",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/VoronoiDiagram",
            exclude: ["Shaders", "Utils/Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_AppleLogo",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/AppleLogo",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ArchimedesSpiral",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ArchimedesSpiral",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_AuthCode",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/AuthCode",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_AutoScrolledTextField",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/AutoScrolledTextField",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_AutoScrolledTextField2",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/AutoScrolledTextField2",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_CircleSDF1",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/CircleSDF1",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_CollisionColorChange",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/CollisionColorChange",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ColoredMap",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ColoredMap",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ColorHexAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ColorHexAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ColorSchemeAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ColorSchemeAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ColorSegmentedControl",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ColorSegmentedControl",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ComplexNumber",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ComplexNumber",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_ContentTransition",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ContentTransition",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_CosmicWeb",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/CosmicWeb",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_CountdownAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/CountdownAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_DateformatStyle",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/DateformatStyle",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Dynamictype",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Dynamictype",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_DynamicTypeScaling",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/DynamicTypeScaling",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_EnumPicker",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/EnumPicker",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_FlipTransition",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/FlipTransition",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_FlowDistortion",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/FlowDistortion",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_FlowLayout",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/FlowLayout",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_GameOfLife",
            dependencies: ["MyToyboxCore", "PlatformSupport"],
            path: "Sources/Screens/GameOfLife",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_GradientAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/GradientAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_GradientPolygon",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/GradientPolygon",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_HierarchicalShapeStyle",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/HierarchicalShapeStyle",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_HomeIconShake",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/HomeIconShake",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_HorizontalPicker",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/HorizontalPicker",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ImplicitEquation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ImplicitEquation",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_InfiniteScroll",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/InfiniteScroll",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_JuliaSet",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/JuliaSet",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_KeyframeAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/KeyframeAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_KuwaharaFilter",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/KuwaharaFilter",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_LayoutProtocolSample",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/LayoutProtocolSample",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_LissajousCurve",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/LissajousCurve",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_LoadingAnimation2",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/LoadingAnimation2",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_LostRowAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/LostRowAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_MatchTopWidth",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/MatchTopWidth",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_MazeGenerator",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/MazeGenerator",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Meshgradient",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Meshgradient",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_MonotoneMap",
            dependencies: ["MyToyboxCore", "Screen_ColoredMap"],
            path: "Sources/Screens/MonotoneMap",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Mosaic",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/Mosaic",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_Motions4",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Motions4",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_MultiHelix",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/MultiHelix",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_PhysicsTag",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/PhysicsTag",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_PipCardDemo",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/PipCardDemo",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_PrettyHip",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/PrettyHip",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_PrimeSpiral",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/PrimeSpiral",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ProgressRing",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ProgressRing",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ProgressiveBlur",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/ProgressiveBlur",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_RadialLayout",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/RadialLayout",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_RandomMetaball2D",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/RandomMetaball2D",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_RealTimeMosic",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/RealTimeMosic",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_RectangleAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/RectangleAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ReverseList",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ReverseList",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Ringanimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Ringanimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Ripple",
            dependencies: ["MyToyboxCore", "MyToyboxMedia"],
            path: "Sources/Screens/Ripple",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_ScrollYRotation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ScrollYRotation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ShaderTile",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/ShaderTile",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_Shine",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Shine",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_SmoothMin",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/SmoothMin",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_SolarSystem1",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/SolarSystem1",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_SolarSystem2",
            dependencies: ["MyToyboxCore", "Screen_SolarSystem1"],
            path: "Sources/Screens/SolarSystem2",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_SpiralLayout",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/SpiralLayout",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_SpiralShader",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/SpiralShader",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_Squreflow",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Squreflow",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_StableFluid",
            dependencies: ["MyToyboxCore", "MyToyboxMedia", "PlatformSupport"],
            path: "Sources/Screens/StableFluid",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_StrokeModifier",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/StrokeModifier",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_TileAnimation",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/TileAnimation",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_TileAnimation3D",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/TileAnimation3D",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_UnevenRoundedRectangle1",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/UnevenRoundedRectangle1",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_UnevenRoundedRectangle2",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/UnevenRoundedRectangle2",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_ViewcontrollerRepresentable",
            dependencies: [
                "MyToyboxCore",
            ],
            path: "Sources/Screens/ViewcontrollerRepresentable",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_Visualeffect",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/Visualeffect",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_WaveCircle",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/WaveCircle",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Screen_WaveParticle",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/WaveParticle",
            exclude: ["Shaders"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "BuildMetalShaders")]
        ),
        .target(
            name: "Screen_WavingText",
            dependencies: ["MyToyboxCore"],
            path: "Sources/Screens/WavingText",
            resources: [.process("Resources")]
        ),

        // MARK: - ClipScreens
        .target(
            name: "ClipScreens",
            dependencies: [
                "MyToyboxCore",
                "RootScreen",
                "Screen_StableFluid",
                "Screen_FlowDistortion",
                "Screen_KuwaharaFilter",
                "Screen_ProgressiveBlur",
                "Screen_Mosaic",
                "Screen_JuliaSet",
                "Screen_SmoothMin",
                "Screen_CircleSDF2",
                "Screen_VoronoiDiagram",
                .product(name: "MetadatasMacros", package: "MetadatasMacros"),
                .product(name: "ScreenMacros", package: "ScreenMacros"),
            ],
            path: "Sources/ClipScreens"
        ),


        // MARK: - TagPicker
        .target(
            name: "TagPicker",
            dependencies: [
                "MyToyboxCore",
            ],
            path: "Sources/Screens/TagPicker",
            resources: [.process("Resources")]
        ),

        // MARK: - AppScreens
        .target(
            name: "AppScreens",
            dependencies: [
                "MyToyboxCore",
                "RootScreen",
                "Screen_AppleLogo",
                "Screen_ArchimedesSpiral",
                "Screen_AuthCode",
                "Screen_AutoScrolledTextField",
                "Screen_AutoScrolledTextField2",
                "Screen_Badge",
                "Screen_CircleSDF1",
                "Screen_CircleSDF2",
                "Screen_CollisionColorChange",
                "Screen_ColoredMap",
                "Screen_ColorHexAnimation",
                "Screen_ColorSchemeAnimation",
                "Screen_ColorSegmentedControl",
                "Screen_ComplexNumber",
                "Screen_ContentTransition",
                "Screen_CosmicWeb",
                "Screen_CountdownAnimation",
                "Screen_DateformatStyle",
                "Screen_DotsSpinner",
                "Screen_Dynamictype",
                "Screen_DynamicTypeScaling",
                "Screen_EnumPicker",
                "Screen_FlipTransition",
                "Screen_FlowDistortion",
                "Screen_FlowLayout",
                "Screen_GameOfLife",
                "Screen_GradientAnimation",
                "Screen_GradientPolygon",
                "Screen_HierarchicalShapeStyle",
                "Screen_HomeIconShake",
                "Screen_HorizontalPicker",
                "Screen_ImplicitEquation",
                "Screen_InfiniteScroll",
                "Screen_JuliaSet",
                "Screen_KeyframeAnimation",
                "Screen_KuwaharaFilter",
                "Screen_LayoutProtocolSample",
                "Screen_LissajousCurve",
                "Screen_LoadingAnimation2",
                "Screen_LostRowAnimation",
                "Screen_MatchTopWidth",
                "Screen_MazeGenerator",
                "Screen_Meshgradient",
                "Screen_MonotoneMap",
                "Screen_Mosaic",
                "Screen_Motions4",
                "Screen_MultiHelix",
                "Screen_PhysicsTag",
                "Screen_PipCardDemo",
                "Screen_PrettyHip",
                "Screen_PrimeSpiral",
                "Screen_ProgressRing",
                "Screen_ProgressiveBlur",
                "Screen_RadialLayout",
                "Screen_RandomMetaball2D",
                "Screen_RealTimeMosic",
                "Screen_RectangleAnimation",
                "Screen_ReverseList",
                "Screen_RingSlider",
                "Screen_Ringanimation",
                "Screen_Ripple",
                "Screen_ScrollYRotation",
                "Screen_ShaderTile",
                "Screen_Shine",
                "Screen_SmoothMin",
                "Screen_SolarSystem1",
                "Screen_SolarSystem2",
                "Screen_SpiralLayout",
                "Screen_SpiralShader",
                "Screen_Squreflow",
                "Screen_StableFluid",
                "Screen_StrokeModifier",
                "Screen_TileAnimation",
                "Screen_TileAnimation3D",
                "Screen_UnevenRoundedRectangle1",
                "Screen_UnevenRoundedRectangle2",
                "Screen_ViewcontrollerRepresentable",
                "Screen_Visualeffect",
                "Screen_VoronoiDiagram",
                "Screen_WaveCircle",
                "Screen_WaveParticle",
                "Screen_WavingText",
                .product(name: "MetadatasMacros", package: "MetadatasMacros"),
                .product(name: "ScreenMacros", package: "ScreenMacros"),
            ],
            path: "Sources/AppScreens"
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
            dependencies: ["MyToyboxCore", "AppScreens", "RootScreen"],
            path: "Tests/MyToyboxCoreTests"
        ),
    ]
)

// Xcode Previews requires each target to be a library product.
package.products += package.targets
    .filter { $0.name.hasPrefix("Screen_") }
    .map { .library(name: $0.name, targets: [$0.name]) }
