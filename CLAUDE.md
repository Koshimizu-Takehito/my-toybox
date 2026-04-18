# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Open project in Xcode
make open
# or
xed .

# Create new screen (interactive or with name)
make new-screen
make new-screen NAME=MyAnimation
make new-screen NAME=MyShader SHADER=yes

# Clean build artifacts
make clean
```

## Build & Test (CI/Command-line)

```bash
# Build
xcodebuild -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  CODE_SIGNING_ALLOWED=NO clean build

# Run all tests
xcodebuild -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  CODE_SIGNING_ALLOWED=NO test

# Run specific test
xcodebuild test -workspace MyToybox.xcworkspace -scheme MyToybox \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.2' \
  -only-testing MyToyboxCoreTests/MyToyboxCoreTests/testName \
  CODE_SIGNING_ALLOWED=NO
```

## Architecture

This is an iOS/macOS visual effects showcase app (Swift 6.0, SwiftUI, Metal) with a modular SPM-based architecture.

**Module Structure:**
- `App/MyToybox/` - Xcode app entry point (`App.swift` → `RootScreen`)
- `Packages/Sources/MyToyboxCore/` - Shared models and utilities (`ScreenMetadata`, `Tag`, `ThumbnailView`)
- `Packages/Sources/MyToyboxScreens/` - Screen implementations, shaders, and `Screen.swift` enum

**Code Generation via SPM Plugins:**
- `BuildMetalShaders` plugin: `.metal` files → `default.metallib`
- `@Screens` macro (from [ScreenMacros](https://github.com/Koshimizu-Takehito/ScreenMacros)): converts `Screen` cases to View types
- `@Metadatas` / `@Metadata` macros (from `MetadatasMacros/`): generate `ScreenMetadata` conformance (`title`, `description`, `tags`, `thumbnail`) for each screen

**Screen Registration:**
- Single source of truth: `Packages/Sources/MyToyboxScreens/Screen.swift`
- Each screen case name must be a valid Swift identifier in lowerCamelCase (e.g., `gameOfLifeScreen`)
- Screen implementations live in `Packages/Sources/MyToyboxScreens/Screens/{ScreenName}/`

**Key Patterns:**
- `@Observable` + `@MainActor` for reactive view models
- MVVM with Use Case pattern for data fetching
- `NavigationSplitView` for adaptive sidebar/detail layouts

## Git Conventions

- Commit messages must follow **Conventional Commits** format (`feat:`, `fix:`, `docs:`, etc.)
- PRs target the `develop` branch
- PR titles must also follow Conventional Commits
