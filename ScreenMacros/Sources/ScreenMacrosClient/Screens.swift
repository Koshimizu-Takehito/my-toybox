import SwiftUI

// MARK: - Screens Protocol

/// A protocol that marks an enum as a screen registry.
///
/// Enums annotated with `@Screens` automatically conform to this protocol,
/// enabling use with navigation helpers like `navigationDestination(_:)`.
///
/// ## Example
///
/// ```swift
/// @Screens
/// enum ScreenID: Hashable {
///     case home
///     case detail(id: Int)
/// }
///
/// // ScreenID automatically conforms to Screens
/// ```
public protocol Screens {}

// MARK: - View Extensions for Navigation

extension View {
    /// Adds a navigation destination for a `Screens`-conforming enum.
    ///
    /// This is a convenience wrapper around `navigationDestination(for:destination:)`
    /// that automatically renders the enum value as a View.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Screens
    /// enum ScreenID: Hashable {
    ///     case home
    ///     case detail(id: Int)
    /// }
    ///
    /// NavigationStack(path: $path) {
    ///     ContentView()
    ///         .navigationDestination(ScreenID.self)
    /// }
    /// ```
    ///
    /// - Parameter type: The `Screens`-conforming enum type.
    /// - Returns: A view with the navigation destination configured.
    @inlinable
    public func navigationDestination<S>(
        _ type: S.Type
    ) -> some View where S: Screens & Hashable & View {
        navigationDestination(for: type) { $0 }
    }
}

// MARK: - View Extensions for Sheet

extension View {
    /// Presents a sheet for a `Screens`-conforming enum.
    ///
    /// This is a convenience wrapper around `sheet(item:content:)`
    /// that automatically renders the enum value as a View.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Screens
    /// enum ModalScreen: Identifiable, Hashable {
    ///     case settings
    ///     case profile(userId: Int)
    ///
    ///     var id: Self { self }
    /// }
    ///
    /// @State private var presentedScreen: ModalScreen?
    ///
    /// ContentView()
    ///     .sheet(item: $presentedScreen)
    /// ```
    ///
    /// - Parameter item: A binding to an optional `Screens` value.
    /// - Returns: A view with the sheet presentation configured.
    @inlinable
    public func sheet<S>(
        item: Binding<S?>
    ) -> some View where S: Screens & Identifiable & View {
        sheet(item: item) { $0 }
    }

    /// Presents a sheet for a `Screens`-conforming enum with dismiss action.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional `Screens` value.
    ///   - onDismiss: A closure to execute when the sheet is dismissed.
    /// - Returns: A view with the sheet presentation configured.
    @inlinable
    public func sheet<S>(
        item: Binding<S?>,
        onDismiss: (() -> Void)?
    ) -> some View where S: Screens & Identifiable & View {
        sheet(item: item, onDismiss: onDismiss) { $0 }
    }
}

// MARK: - View Extensions for FullScreenCover

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension View {
    /// Presents a full-screen cover for a `Screens`-conforming enum.
    ///
    /// This is a convenience wrapper around `fullScreenCover(item:content:)`
    /// that automatically renders the enum value as a View.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Screens
    /// enum FullScreen: Identifiable, Hashable {
    ///     case onboarding
    ///     case login
    ///
    ///     var id: Self { self }
    /// }
    ///
    /// @State private var fullScreen: FullScreen?
    ///
    /// ContentView()
    ///     .fullScreenCover(item: $fullScreen)
    /// ```
    ///
    /// - Parameter item: A binding to an optional `Screens` value.
    /// - Returns: A view with the full-screen cover configured.
    @inlinable
    public func fullScreenCover<S>(
        item: Binding<S?>
    ) -> some View where S: Screens & Identifiable & View {
        fullScreenCover(item: item) { $0 }
    }

    /// Presents a full-screen cover for a `Screens`-conforming enum with dismiss action.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional `Screens` value.
    ///   - onDismiss: A closure to execute when the cover is dismissed.
    /// - Returns: A view with the full-screen cover configured.
    @inlinable
    public func fullScreenCover<S>(
        item: Binding<S?>,
        onDismiss: (() -> Void)?
    ) -> some View where S: Screens & Identifiable & View {
        fullScreenCover(item: item, onDismiss: onDismiss) { $0 }
    }
}
#endif

// MARK: - ForEach Helper

/// Creates a `ForEach` that iterates over all cases of a `Screens`-conforming enum.
///
/// This is useful for creating tab views or lists that display all screens.
///
/// ## Example
///
/// ```swift
/// @Screens
/// enum TabScreen: CaseIterable, Hashable {
///     case home
///     case search
///     case profile
/// }
///
/// TabView {
///     ScreensForEach(TabScreen.self) { screen in
///         screen.tabItem {
///             Label(screen.title, systemImage: screen.icon)
///         }
///     }
/// }
/// ```
public struct ScreensForEach<S: Screens & CaseIterable & Hashable, Content: View>: View {
    private let content: (S) -> Content

    /// Creates a `ScreensForEach` view.
    ///
    /// - Parameters:
    ///   - type: The `Screens`-conforming enum type.
    ///   - content: A closure that creates content for each case.
    public init(
        _ type: S.Type,
        @ViewBuilder content: @escaping (S) -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        ForEach(Array(S.allCases), id: \.self, content: content)
    }
}

/// Creates a `ForEach` that renders all cases of a `Screens`-conforming enum as Views.
///
/// ## Example
///
/// ```swift
/// @Screens
/// enum TabScreen: CaseIterable, Hashable {
///     case home
///     case search
///     case profile
/// }
///
/// VStack {
///     ScreensForEachView(TabScreen.self)
/// }
/// ```
public struct ScreensForEachView<S: Screens & CaseIterable & Hashable & View>: View {
    /// Creates a `ScreensForEachView`.
    ///
    /// - Parameter type: The `Screens`-conforming enum type.
    public init(_ type: S.Type) {}

    public var body: some View {
        ForEach(Array(S.allCases), id: \.self) { $0 }
    }
}
