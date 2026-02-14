# ``ScreenMacros``

Generate type-safe SwiftUI views from enums using Swift macros.

## Overview

ScreenMacros is a Swift macro package that automatically generates `View` protocol conformance for enums, enabling type-safe screen-to-view mapping in SwiftUI applications.

```swift
@Screens
enum Screen {
    case home
    case detail(id: Int)
}

// Screen can now be used directly as a SwiftUI View
NavigationStack(path: $path) {
    Home()
        .navigationDestination(Screen.self)
}
```

## Topics

### Essentials

- <doc:GettingStarted>

### Macros

- ``Screens()``
- ``Screen(_:)``
- ``Screen(_:_:)``
- ``Screen()``

### Protocols

- ``Screens``

### Navigation Helpers

- ``SwiftUI/View/navigationDestination(_:)``
- ``SwiftUI/View/sheet(item:)``
- ``SwiftUI/View/sheet(item:onDismiss:)``
- ``SwiftUI/View/fullScreenCover(item:)``
- ``SwiftUI/View/fullScreenCover(item:onDismiss:)``

### ForEach Helpers

- ``ScreensForEach``
- ``ScreensForEachView``

