## ScreenMacros

**ScreenMacros** is a Swift macro package that turns an enum of screen identifiers
into type-safe SwiftUI views.

You annotate an enum with `@ScreenRegistry` and optionally each case with `@Screen`,
and the macro generates a `View` conformance that switches over all cases.

```swift
import SwiftUI
import ScreenMacrosClient

@ScreenRegistry
enum ScreenID {
    case homeScreen
    case detailScreen(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

After macro expansion:

```swift
extension ScreenID: View {
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

Add **ScreenMacros** as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(path: "../ScreenMacros")  // Local package reference
    // Or for remote:
    // .package(url: "https://github.com/Koshimizu-Takehito/my-toybox.git", from: "0.1.0")
]
```

And use the client module in your target:

```swift
.target(
    name: "YourFeature",
    dependencies: [
        .product(name: "ScreenMacrosClient", package: "ScreenMacros")
    ]
)
```

---

## Macros

### `@ScreenRegistry`

- **Attached to**: enum  
- **Generates**:
  - `extension <Enum>: View`
  - `var body: some View`

If no `@Screen` attributes are present, types are inferred from case names by
converting them to UpperCamelCase:

```swift
@ScreenRegistry
enum ScreenID {
    case gameOfLifeScreen  // → GameOfLifeScreen()
    case mosaicScreen      // → MosaicScreen()
}
```

### `@Screen`

- **Attached to**: enum case  
- **Purpose**: Override the inferred view type and/or map parameter labels.

```swift
@ScreenRegistry
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
@ScreenRegistry
public enum ScreenID {
    case homeScreen
}
```

expands to:

```swift
public enum ScreenID {
    case homeScreen
}

public extension ScreenID: View {
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

`@ScreenRegistry` does **not depend on the concrete types** of associated values.
It simply:

- Binds each case parameter to a local `let` binding
- Forwards those bindings to the inferred or specified View initializer

This means cases with `Optional` or `Result` work out of the box:

```swift
@ScreenRegistry
enum ScreenID {
    case optionalDetail(id: Int?)
    case loadResult(result: Result<Int, Error>)
}
```

The macro expands to:

```swift
extension ScreenID: View {
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
@ScreenRegistry
enum ScreenID {
    @Screen(ProfileView.self, ["userId": "id", "showEdit": "editable"])
    case profile(userId: Int, showEdit: Bool)
}
```

expands to:

```swift
extension ScreenID: View {
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


