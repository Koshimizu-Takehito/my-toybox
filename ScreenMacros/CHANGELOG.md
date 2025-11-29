# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-11-29

### Added

- `@Screens` macro for automatic `View` and `Screens` protocol conformance
- `@Screen` macro for explicit View type specification
- Associated values support with automatic parameter binding
- Parameter mapping for renaming case labels to View initializer parameters
- Generics and module-qualified type support
- Access level auto-adjustment (public/internal/fileprivate/private)
- Unused mapping key warnings
- SwiftUI navigation helpers:
  - `navigationDestination(_:)` for NavigationStack
  - `sheet(item:)` for modal presentation
  - `fullScreenCover(item:)` for full-screen presentation (iOS/tvOS/watchOS/visionOS)
- ForEach helpers:
  - `ScreensForEach` for custom content iteration
  - `ScreensForEachView` for direct View rendering

### Requirements

- Swift 6.0+
- iOS 17.0+ / macOS 14.0+

[Unreleased]: https://github.com/Koshimizu-Takehito/ScreenMacros/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Koshimizu-Takehito/ScreenMacros/releases/tag/v1.0.0

