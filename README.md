# my-toybox

![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-6.1-orange.svg)
![MIT](https://img.shields.io/badge/license-MIT-black)

**my-toybox** is an experimental iOS app project that showcases a wide variety of SwiftUI and Metal-based visual effects and animations.  
It acts as a sandbox or "toybox" of interactive screens where you can explore different UI techniques and graphics rendering approaches.

## Overview

- **Languages & Frameworks**: Swift, SwiftUI, Metal  
- **Project Format**: Xcode project (`MyToybox.xcodeproj`)  
- **Platform**: iOS (iPhone/iPad), recommended with Xcode 16.2 or later  

The app displays a list of sample screens (referred to as "screens") on launch. Each screen demonstrates a unique animation or visual effect.  
Screens are loaded dynamically from a bundled JSON file and rendered using SwiftUI and, in some cases, custom Metal shaders.

## Key Features

### 🔹 Dozens of Sample Screens
Each screen lives under `Sources/Screens/` and showcases a specific animation, layout, or rendering technique.  
The screen list is defined using `Screen.swift`, `ScreenID.swift`, and loaded from a `Screens.json` file.

### 🔹 Metal Shaders
Some effects (like mosaic or particle waves) are implemented with `.metal` shader files using SwiftUI’s shader support.

### 🔹 Modern SwiftUI & Concurrency
- Uses `async/await` for loading screen metadata asynchronously.
- Applies `@Observable` (available from Swift 5.9+) for reactive state management.
- Embraces SwiftUI idioms like `NavigationSplitView` for adaptive layouts.

### 🔹 Adaptive Navigation
- On iPad or in landscape, a sidebar and detail panel are shown via `NavigationSplitView`.
- On compact devices (e.g., iPhones in portrait), tapping a screen pushes to its detail view.
- The first screen auto-selects by default on regular-width devices.

## Project Structure

```
my-toybox/
  ├─ MyToybox.xcodeproj/         # Xcode project
  ├─ MyToybox/
  │   ├─ Resources/
  │   │   └─ Assets.xcassets/    # App icons and image assets
  │   ├─ Sources/
  │   │   ├─ App/
  │   │   │   └─ App.swift       # Entry point of the app
  │   │   ├─ Screens/
  │   │   │   ├─ Root/           # Root screen and view model
  │   │   │   ├─ Screens/         # Dozens of animation screens
  │   │   └─ ...
```

- `App.swift`: The app's `@main` entry point, launching the `RootScreen`.
- `RootScreen.swift`: The master-detail view listing all available screens.
- `RootScreenViewModel.swift`: Handles loading and storing screen data.
- `Screens.json`: A static metadata file describing available screens (ID, title, description, etc.).

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Koshimizu-Takehito/my-toybox.git
   ```

2. **Open in Xcode**
   - Open `MyToybox.xcodeproj`.

3. **Build and run**
   - Choose a simulator or real device and run the app via Xcode.

## How to Use

- On launch, the app displays a list of demo screens.
- Tap (or click) a screen to open it in the detail panel or navigation stack.
- On iPads or large screens, you’ll see both the sidebar and selected content side-by-side.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Koshimizu-Takehito/my-toybox/blob/main/LICENSE) file for details.

## Author

- Maintained by: *[Koshimizu-Takehito](https://github.com/Koshimizu-Takehito)*
