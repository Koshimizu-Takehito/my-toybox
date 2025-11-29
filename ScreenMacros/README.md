# ScreenMacros

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%2017+%20|%20macOS%2014+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**ScreenMacros** is a Swift macro package that turns an enum of screen identifiers
into type-safe SwiftUI views.

You annotate an enum with `@Screens` and optionally each case with `@Screen`,
and the macro generates `View` and `Screens` conformances that switch over all cases.

```swift
import SwiftUI
import ScreenMacros

@Screens
enum ScreenID {
    case homeScreen
    case detailScreen(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

After macro expansion:

```swift
extension ScreenID: View, ScreenMacros.Screens {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .homeScreen:
            HomeScreen()
        case .detailScreen(id: let id):
            DetailScreen(id: id)
        case .loadResult(result: let result):
            LoadResult(result: result)
        }
    }
}
```

You can now use `ScreenID` directly as a SwiftUI `View`.

---

## Installation

### Swift Package Manager

Add **ScreenMacros** as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Koshimizu-Takehito/ScreenMacros.git", from: "1.0.0")
]
```

And add it to your target:

```swift
.target(
    name: "YourFeature",
    dependencies: [
        .product(name: "ScreenMacros", package: "ScreenMacros")
    ]
)
```

### Xcode

1. File → Add Package Dependencies...
2. Enter: `https://github.com/Koshimizu-Takehito/ScreenMacros.git`
3. Select version: `1.0.0` or later

---

## Macros

### `@Screens`

- **Attached to**: enum  
- **Generates**:
  - `extension <Enum>: View, Screens`
  - `var body: some View`

If no `@Screen` attributes are present, types are inferred from case names by
converting them to UpperCamelCase:

```swift
@Screens
enum ScreenID {
    case gameOfLifeScreen  // → GameOfLifeScreen()
    case mosaicScreen      // → MosaicScreen()
}
```

### `@Screen`

- **Attached to**: enum case  
- **Purpose**: Override the inferred view type and/or map parameter labels.

```swift
@Screens
enum ScreenID {
    @Screen(CustomView.self)
    case customScreen

    @Screen(DetailView.self, ["id": "detailId"])
    case detail(id: Int)

    @Screen(["foo": "image"])
    case multiColorImage(foo: Image, colors: [Color])
}
```

---

## Access Control Auto-Adjustment

**ScreenMacros automatically mirrors the access level of the source enum.**

- **Access level mapping**
  - `public enum` → `public extension` / `public var body`
  - `internal enum` (including no modifier) → `internal extension` / `internal var body`
  - `fileprivate` / `private` enums → `fileprivate extension` / `fileprivate var body`, `private extension` / `private var body` respectively.

Example:

```swift
@Screens
public enum ScreenID {
    case homeScreen
}
```

expands to:

```swift
public enum ScreenID {
    case homeScreen
}

public extension ScreenID: View, ScreenMacros.Screens {
    @MainActor @ViewBuilder
    public var body: some View {
        switch self {
        case .homeScreen:
            HomeScreen()
        }
    }
}
```

This prevents accidental mismatches such as an `internal enum` with a `public body`,
and makes it safe to expose `public` APIs from libraries.

---

## Associated Values with Optional / Result

`@Screens` does **not depend on the concrete types** of associated values.
It simply:

- Binds each case parameter to a local `let` binding
- Forwards those bindings to the inferred or specified View initializer

This means cases with `Optional` or `Result` work out of the box:

```swift
@Screens
enum ScreenID {
    case optionalDetail(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

The macro expands to:

```swift
extension ScreenID: View, ScreenMacros.Screens {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .optionalDetail(id: let id):
            OptionalDetail(id: id)
        case .loadResult(result: let result):
            LoadResult(result: result)
        }
    }
}
```

The same rule applies to other complex generic types (e.g. `[String]`, `Result<[User], Error>`, etc.),
so you can freely use them in your screen enums.

---

## Parameter Mapping

When the case labels and the View initializer parameter names differ,
you can provide a mapping via `@Screen`:

```swift
@Screens
enum ScreenID {
    @Screen(ProfileView.self, ["userId": "id", "showEdit": "editable"])
    case profile(userId: Int, showEdit: Bool)
}
```

expands to:

```swift
extension ScreenID: View, ScreenMacros.Screens {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .profile(userId: let userId, showEdit: let showEdit):
            ProfileView(id: userId, editable: showEdit)
        }
    }
}
```

Keys in the mapping must match the case parameter labels.
Unmapped parameters are passed through unchanged.

---

## Navigation Helpers

Enums annotated with `@Screens` automatically conform to the `Screens` protocol,
which enables convenient navigation helpers.

### NavigationStack

Use `navigationDestination(_:)` to register a navigation destination:

```swift
@Screens
enum ScreenID: Hashable {
    case home
    case detail(id: Int)
}

struct ContentView: View {
    @State private var path: [ScreenID] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(ScreenID.self)
        }
    }
}
```

This is equivalent to the more verbose:

```swift
.navigationDestination(for: ScreenID.self) { screen in
    screen
}
```

### Sheet

Use `sheet(item:)` to present a sheet:

```swift
@Screens
enum ModalScreen: Hashable, Identifiable {
    case settings
    case profile(userId: Int)

    var id: Self { self }
}

struct ContentView: View {
    @State private var presentedScreen: ModalScreen?

    var body: some View {
        Button("Show Settings") {
            presentedScreen = .settings
        }
        .sheet(item: $presentedScreen)
    }
}
```

### FullScreenCover (iOS / tvOS / watchOS / visionOS)

Use `fullScreenCover(item:)` for full-screen presentations:

```swift
@Screens
enum FullScreen: Hashable, Identifiable {
    case onboarding
    case login

    var id: Self { self }
}

struct ContentView: View {
    @State private var fullScreen: FullScreen?

    var body: some View {
        Button("Start Onboarding") {
            fullScreen = .onboarding
        }
        .fullScreenCover(item: $fullScreen)
    }
}
```

---

## ForEach Helpers

### ScreensForEach

Iterates over all cases of a `CaseIterable` enum with custom content:

```swift
@Screens
enum TabScreen: CaseIterable, Hashable {
    case home
    case search
    case profile

    var title: String { ... }
    var icon: String { ... }
}

TabView {
    ScreensForEach(TabScreen.self) { screen in
        screen.tabItem {
            Label(screen.title, systemImage: screen.icon)
        }
    }
}
```

### ScreensForEachView

Renders all cases directly as Views:

```swift
VStack {
    ScreensForEachView(TabScreen.self)
}
```


