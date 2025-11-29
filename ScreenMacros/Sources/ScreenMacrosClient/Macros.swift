import SwiftUI

// MARK: - @ScreenRegistry (Attached Macro - Extension + MemberAttribute)

/// Macro applied to an enum that automatically generates `View` conformance and a `body` property.
///
/// - For cases without a `@Screen` attribute, `@Screen` is added automatically (for metadata).
/// - Type resolution itself works even without `@Screen`; the case name is converted to UpperCamelCase
///   and used as the View type.
///
/// ## Example
///
/// ```swift
/// @ScreenRegistry
/// enum ScreenID: String {
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
/// enum ScreenID: String {
///     @Screen
///     case gameOfLifeScreen
///     @Screen
///     case mosaicScreen
///
///     @Screen(CustomView.self)
///     case customScreen
/// }
///
/// extension ScreenID: View {
///     @MainActor @ViewBuilder
///     public var body: some View {
///         switch self {
///         case .gameOfLifeScreen: GameOfLifeScreen()
///         case .mosaicScreen: MosaicScreen()
///         case .customScreen: CustomView()
///         }
///     }
/// }
/// ```
@attached(extension, conformances: View, names: named(body))
@attached(memberAttribute)
public macro ScreenRegistry() = #externalMacro(
    module: "ScreenMacrosImpl",
    type: "ScreenRegistryMacro"
)

// MARK: - @Screen (Attached Macro - Peer)

/// Macro applied to an enum case to specify the corresponding View type.
///
/// When using `@ScreenRegistry`, `@Screen` is added automatically.
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
/// ## With arguments
///
/// Explicitly specify a View type.
///
/// ```swift
/// @Screen(CustomView.self)
/// case myScreen  // → CustomView()
/// ```
///
/// - Parameter viewType: The View type corresponding to this case (optional).
@attached(peer)
public macro Screen<V: View>(_ viewType: V.Type) = #externalMacro(
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

