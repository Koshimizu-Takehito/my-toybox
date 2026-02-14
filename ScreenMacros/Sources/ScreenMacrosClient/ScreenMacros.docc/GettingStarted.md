# Getting Started

Learn how to use ScreenMacros to create type-safe SwiftUI navigation.

## Overview

ScreenMacros simplifies SwiftUI navigation by automatically generating `View` conformance for enums. This guide walks you through the basic setup and common usage patterns.

## Installation

Add ScreenMacros to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Koshimizu-Takehito/ScreenMacros.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ScreenMacros", package: "ScreenMacros")
    ]
)
```

## Define Your Screens

Create an enum to represent your screens and annotate it with `@Screens`:

```swift
import ScreenMacros
import SwiftUI

@Screens
enum Screen: Hashable {
    case home
    case detail(id: Int)
    case preview(Int)
    case search
}
```

The macro automatically generates a `body` property that maps each case to its corresponding view:

```swift
// Generated code
extension Screen: View, ScreenMacros.Screens {
    @MainActor @ViewBuilder
    var body: some View {
        switch self {
        case .home:
            Home()
        case .detail(id: let id):
            Detail(id: id)
        case .preview(let param0):
            Preview(param0)
        case .search:
            Search()
        }
    }
}
```

## Create Your Views

Create SwiftUI views matching your enum case names (in UpperCamelCase):

```swift
struct Home: View {
    var body: some View {
        Text("Home Screen")
    }
}

struct Detail: View {
    let id: Int
    
    var body: some View {
        Text("Detail: \(id)")
    }
}

struct Preview: View {
    let itemId: Int
    
    init(_ itemId: Int) {
        self.itemId = itemId
    }
    
    var body: some View {
        Text("Preview: \(itemId)")
    }
}

struct Search: View {
    var body: some View {
        Text("Search")
    }
}
```

## Use with NavigationStack

Use the `navigationDestination(_:)` helper for seamless navigation:

```swift
struct ContentView: View {
    @State private var path: [Screen] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to Detail") {
                    path.append(.detail(id: 42))
                }
            }
            .navigationDestination(Screen.self)
        }
    }
}
```

## Use with Sheet

For modal presentations, use the `sheet(item:)` helper:

```swift
@Screens
enum ModalScreen: Hashable, Identifiable {
    case settings
    case editProfile(userId: Int)
    
    var id: Self { self }
}

struct ContentView: View {
    @State private var presentedModal: ModalScreen?
    
    var body: some View {
        Button("Show Settings") {
            presentedModal = .settings
        }
        .sheet(item: $presentedModal)
    }
}
```

## Use with FullScreenCover

For full-screen presentations, use the `fullScreenCover(item:)` helper:

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

## Custom View Mapping

When you need a different view type than the inferred name, use `@Screen`:

```swift
@Screens
enum Screen: Hashable {
    case home
    case detail(id: Int)
    
    @Screen(ProfileView.self, ["userId": "id"])
    case profile(userId: Int)
}
```

This maps the `profile(userId:)` case to `ProfileView(id:)`, converting the `userId` parameter to `id`.

## Unlabeled Associated Values

When an associated value has no label, it is passed to the View without a label. This works seamlessly with Views that have unlabeled initializer parameters:

```swift
@Screens
enum Screen: Hashable {
    case preview(Int)  // → Preview(param0) - passed without label
}

struct Preview: View {
    let itemId: Int
    
    init(_ itemId: Int) {  // Unlabeled initializer
        self.itemId = itemId
    }
    
    var body: some View {
        Text("Preview: \(itemId)")
    }
}
```

If you need to add a label to an unlabeled parameter, use the mapping:

```swift
@Screen(["param0": "id"])
case preview(Int)  // → Preview(id: param0)
```

You can also use `"_"` as the mapping value when you want to remove a label from a labeled parameter:

```swift
@Screen(Detail.self, ["id": "_"])
case detail(id: Int)  // → Detail(id) – passed without label
```

## Next Steps

- Explore parameter mapping with ``Screen(_:_:)``
- Learn about ``ScreensForEach`` for TabView integration
- Check out the [Example project](https://github.com/Koshimizu-Takehito/ScreenMacros/tree/main/Example) for complete usage patterns

