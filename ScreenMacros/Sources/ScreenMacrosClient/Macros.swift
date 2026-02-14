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
/// enum Screen: Hashable {
///     case home           // Automatically gets @Screen → Home()
///     case detail(id: Int) // Automatically gets @Screen → Detail(id: id)
///     case search         // Automatically gets @Screen → Search()
///
///     @Screen(ProfileView.self, ["userId": "id"])
///     case profile(userId: Int)  // Explicitly specified → ProfileView(id: userId)
/// }
/// ```
///
/// ## Unlabeled Associated Values
///
/// When an associated value has no label, it is passed to the View without a label.
/// This allows Views with unlabeled initializer parameters to work seamlessly.
///
/// ```swift
/// @Screens
/// enum Screen: Hashable {
///     case preview(Int)                 // → Preview(param0) - passed without label
///     case article(Int, title: String)  // → Article(param0, title: title)
/// }
/// ```
///
/// ## After macro expansion
///
/// ```swift
/// enum Screen: Hashable {
///     @Screen
///     case home
///     @Screen
///     case detail(id: Int)
///     @Screen
///     case search
///
///     @Screen(ProfileView.self, ["userId": "id"])
///     case profile(userId: Int)
/// }
///
/// extension Screen: View, ScreenMacros.Screens {
///     @MainActor @ViewBuilder
///     var body: some View {
///         switch self {
///         case .home:
///             Home()
///         case .detail(id: let id):
///             Detail(id: id)
///         case .search:
///             Search()
///         case .profile(userId: let userId):
///             ProfileView(id: userId)
///         }
///     }
/// }
/// ```
///
/// ## Usage with SwiftUI Navigation
///
/// ```swift
/// NavigationStack(path: $path) {
///     Home()
///         .navigationDestination(Screen.self)
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
/// case home  // → Home()
/// ```
///
/// ## With View type only
///
/// Explicitly specify a View type.
///
/// ```swift
/// @Screen(ProfileView.self)
/// case profile  // → ProfileView()
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
/// - For unlabeled associated values, use the generated parameter names (`param0`, `param1`, ...) as keys.
/// - A mapping value of `"_"` means "call the initializer without a label" for that parameter.
///
/// ```swift
/// @Screen(ProfileView.self, ["userId": "id"])
/// case profile(userId: Int)  // → ProfileView(id: userId)
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
/// @Screen(ProfileView.self, ["userId": "id"])
/// case profile(userId: Int)  // → ProfileView(id: userId)
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
/// @Screen(["userId": "id"])
/// case editProfile(userId: Int)
/// // → EditProfile(id: userId)
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
