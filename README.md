# my-toybox

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.0-orange.svg)
![MIT](https://img.shields.io/badge/license-MIT-black)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/my-toybox)

![Simulator Screenshot - iPad Pro 13-inch (M4) - 2025-05-11 at 15 32 02](https://github.com/user-attachments/assets/8b5ecc14-1224-4de7-9160-622aee2fb723)

**my-toybox** is an experimental iOS/macOS app project that showcases a wide variety of SwiftUI and Metal-based visual effects and animations.  
It acts as a sandbox or "toybox" of interactive screens where you can explore different UI techniques and graphics rendering approaches.

## Overview

- **Languages & Frameworks**: Swift 6.0, SwiftUI, Metal  
- **Project Format**: Xcode workspace (`MyToybox.xcworkspace`)  
- **Platform**: iOS 18+ (iPhone/iPad), macOS 15+  
- **Recommended**: Xcode 16.3 or later  

The app displays a list of sample screens (referred to as "screens") on launch. Each screen demonstrates a unique animation or visual effect.  
Screens are loaded dynamically from the `Screen` enum and rendered using SwiftUI and, in some cases, custom Metal shaders.

## Key Features

### 🔹 Dozens of Sample Screens
Each screen lives under `Packages/Sources/MyToyboxScreens/Screens/` and showcases a specific animation, layout, or rendering technique.  
The screen list is defined using `Screen.swift`.  
Each case name in `enum Screen` **must be a valid Swift identifier in lowerCamelCase (e.g. `gameOfLifeScreen`)**.

### 🔹 SPM Build Tool Plugins
This project uses SPM plugins to automatically compile resources during build:

| Plugin | Input | Output |
|--------|-------|--------|
| `BuildMetalShaders` | `.metal` files | `default.metallib` (compiled shaders) |

The `@Screens` macro ([ScreenMacros](https://github.com/Koshimizu-Takehito/ScreenMacros)) converts each `Screen` case into a corresponding `View` type.

### 🔹 Metal Shaders
Some effects (like mosaic or particle waves) are implemented with `.metal` shader files using SwiftUI's shader support.

### 🔹 Modern SwiftUI & Concurrency
- Uses `async/await` for loading screen metadata asynchronously.
- Applies `@Observable` for reactive state management.
- Embraces SwiftUI idioms like `NavigationSplitView` for adaptive layouts.

### 🔹 Adaptive Navigation
- On iPad or in landscape, a sidebar and detail panel are shown via `NavigationSplitView`.
- On compact devices (e.g., iPhones in portrait), tapping a screen pushes to its detail view.
- The first screen auto-selects by default on regular-width devices.

## Project Structure

```
my-toybox/
  ├─ MyToybox.xcworkspace/         # Xcode workspace (open with xed .)
  ├─ Makefile                      # Build commands (see below)
  ├─ App/
  │   ├─ MyToybox.xcodeproj/       # Xcode project
  │   └─ MyToybox/
  │       ├─ App.swift             # Entry point of the app
  │       └─ Resources/
  │           └─ Assets.xcassets/  # App icons and image assets
  ├─ Packages/                     # Swift Package
  │   ├─ Package.swift             # Swift Package definition
  │   ├─ Plugins/
  │   │   └─ BuildMetalShaders/    # SPM plugin for Metal compilation
  │   ├─ Sources/
  │   │   ├─ MyToyboxCore/         # Core protocols and shared utilities
  │   │   │   ├─ ScreenMetadata.swift  # Protocol defining screen metadata & thumbnail
  │   │   │   ├─ Tag.swift             # Tag enum for screen categorization
  │   │   │   └─ ThumbnailView.swift   # Reusable thumbnail view wrapper
  │   │   └─ MyToyboxScreens/      # All screen implementations
  │   │       ├─ Screen.swift      # Screen enum definition
  │   │       ├─ Exports.swift     # Public API exports
  │   │       ├─ Screens/          # Dozens of animation screens
  │   │       │   └─ Root/         # Root screen and view model
  │   │       ├─ Shaders/          # Metal shader files
  │   │       ├─ TagPicker/        # Tag filter UI components
  │   │       ├─ Utils/            # Utilities and Metal shader headers
  │   │       └─ Resources/        # Bundle resources (assets, xibs)
  │   └─ Tests/
  │       └─ MyToyboxCoreTests/    # Unit tests for core module
  ├─ MetadatasMacros/              # @Metadatas / @Metadata macro package
  ├─ ScreenMacros/                 # @Screens / @Screen macro package
  └─ Scripts/
      ├─ build_metallib.sh         # Metal shader build script (used by plugin)
      ├─ new_screen.sh             # Script to create new screens
      └─ check_screen_sync.sh      # Validates screen consistency
```

**Key Files:**
- `App.swift`: The app's `@main` entry point, launching the `RootScreen`.
- `RootScreen.swift`: The master-detail view listing all available screens.
- `RootViewModel.swift`: Handles loading and storing screen data.
- `Screen.swift`: Enum defining all available screens with their metadata.

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/Koshimizu-Takehito/my-toybox.git
cd my-toybox
```

### 2. Open in Xcode
```bash
make open
# or
xed .
```
- This opens `MyToybox.xcworkspace` containing both the app and SPM packages.
- Or open `Packages/Package.swift` for SPM-only development.

> **Note**: Metal shaders are automatically compiled by SPM plugins during build.

### 3. Build and run
- Choose a simulator or real device and run the app via Xcode.

## Makefile Commands

This project includes a `Makefile` for common development tasks:

| Command | Description |
|---------|-------------|
| `make help` | Show available commands |
| `make open` | Open project in Xcode |
| `make setup` | Install Mint (if needed) and dependencies |
| `make sync` | Pull latest changes and update dependencies |
| `make new-screen` | Create a new screen (interactive) |
| `make new-screen NAME=Foo` | Create a new screen named `Foo` |
| `make new-screen NAME=Foo SHADER=yes` | Create a new screen with Metal shader |
| `make lint` | Run SwiftLint |
| `make lint-fix` | Run SwiftLint with auto-correction |
| `make lint-strict` | Run SwiftLint treating warnings as errors (for CI) |
| `make format` | Format code with SwiftFormat |
| `make format-check` | Check code formatting (no changes) |
| `make fix` | Format and auto-fix all code |
| `make clean` | Remove build artifacts |

### Creating a New Screen

```bash
# Interactive mode
make new-screen

# Direct creation
make new-screen NAME=MyNewAnimation

# With Metal shader support
make new-screen NAME=MyShaderEffect SHADER=yes
```

## How to Use

- On launch, the app displays a list of demo screens.
- Tap (or click) a screen to open it in the detail panel or navigation stack.
- On iPads or large screens, you'll see both the sidebar and selected content side-by-side.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Koshimizu-Takehito/my-toybox/blob/main/LICENSE) file for details.

## Author

- Maintained by: *[Koshimizu-Takehito](https://github.com/Koshimizu-Takehito)*
