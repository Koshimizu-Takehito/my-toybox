import SwiftUI

// MARK: - @Screens (Attached Macro - Extension + MemberAttribute)

/// Macro applied to an enum that automatically generates `View` and `Screens` conformance.
///
/// - For cases without a `@Screen` attribute, `@Screen` is added automatically (for metadata).
/// - Type resolution itself works even without `@Screen`; the case name is converted to UpperCamelCase
///   and used as the View type.
///
/// ## Example
///
/// ```swift
/// @Screens
/// enum ScreenID: Hashable {
///     case gameOfLifeScreen    // Automatically gets @Screen → GameOfLifeScreen()
///     case mosaicScreen        // Automatically gets @Screen → MosaicScreen()
///
///     @Screen(CustomView.self)
///     case customScreen        // Explicitly specified → CustomView()
/// }
/// ```
///
/// ## After macro expansion
///
/// ```swift
/// enum ScreenID: Hashable {
///     @Screen
///     case gameOfLifeScreen
///     @Screen
///     case mosaicScreen
///
///     @Screen(CustomView.self)
///     case customScreen
/// }
///
/// extension ScreenID: View, ScreenMacros.Screens {
///     @MainActor @ViewBuilder
///     var body: some View {
///         switch self {
///         case .gameOfLifeScreen: GameOfLifeScreen()
///         case .mosaicScreen: MosaicScreen()
///         case .customScreen: CustomView()
///         }
///     }
/// }
/// ```
///
/// ## Usage with SwiftUI Navigation
///
/// ```swift
/// NavigationStack(path: $path) {
///     ContentView()
///         .navigationDestination(ScreenID.self)
/// }
/// ```
@attached(extension, conformances: View, Screens, names: named(body))
@attached(memberAttribute)
public macro Screens() = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreensMacro"
)

// MARK: - @Screen (Attached Macro - Peer)

/// Macro applied to an enum case to specify the corresponding View type.
///
/// When using `@Screens`, `@Screen` is added automatically.
/// Explicitly specify it only when you want to use a different View type from the case name.
///
/// ## Without arguments (recommended)
///
/// The case name is converted to UpperCamelCase and used as the View type.
///
/// ```swift
/// @Screen
/// case appleLogoScreen  // → AppleLogoScreen()
/// ```
///
/// ## With View type only
///
/// Explicitly specify a View type.
///
/// ```swift
/// @Screen(CustomView.self)
/// case myScreen  // → CustomView()
/// ```
///
/// ## With module-qualified or generic types
///
/// Supports module-qualified types, generics, and combinations.
/// The referenced View type must be visible in scope (e.g. imported or in the same module).
///
/// ```swift
/// @Screen(SomeModule.CustomView.self)
/// case moduleQualified  // → SomeModule.CustomView()
///
/// @Screen(GenericView<Int>.self)
/// case genericView  // → GenericView<Int>()
///
/// @Screen(SomeModule.GenericView<Int, String>.self)
/// case fullyQualified  // → SomeModule.GenericView<Int, String>()
/// ```
///
/// ## With View type and parameter mapping (for associated values)
///
/// Specify a mapping from case parameter names to View initializer parameter names.
/// - Keys must be string literals matching the case's parameter labels
///   (e.g. `id`, `userId`). Unused keys are ignored.
///
/// ```swift
/// @Screen(DetailView.self, ["id": "detailId"])
/// case detail(id: Int)  // → DetailView(detailId: id)
/// ```
///
/// - Parameter viewType: The View type corresponding to this case (optional).
/// - Parameter mapping: A dictionary mapping case parameter names to View initializer parameter names.
@attached(peer)
public macro Screen<V: View>(_ viewType: V.Type) = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreenMacro"
)

/// `@Screen` macro with View type and parameter mapping.
///
/// Use this when the case's associated value labels differ from the View's initializer parameter names.
///
/// ```swift
/// @Screen(DetailView.self, ["id": "detailId"])
/// case detail(id: Int)  // → DetailView(detailId: id)
/// ```
@attached(peer)
public macro Screen<V: View>(_ viewType: V.Type, _ mapping: [String: String]) = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreenMacro"
)

/// `@Screen` macro with parameter mapping only.
///
/// The View type is inferred from the case name (converted to UpperCamelCase).
/// Use this when you only need to remap parameter names.
/// - Keys must be string literals matching the case's parameter labels.
///
/// ```swift
/// @Screen(["foo": "image"])
/// case multiColorImage(foo: Image, colors: [Color])
/// // → MultiColorImage(image: foo, colors: colors)
/// ```
@attached(peer)
public macro Screen(_ mapping: [String: String]) = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreenMacro"
)

/// `@Screen` macro without arguments.
///
/// The case name is converted to UpperCamelCase and used as the View type.
@attached(peer)
public macro Screen() = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreenMacro"
)

