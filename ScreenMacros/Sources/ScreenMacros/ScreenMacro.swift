import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - ScreenMacro

/// Implementation of the `@Screen` macro.
///
/// This macro works as a marker to hold metadata.
/// Actual code generation is handled by the `@Screens` macro.
///
/// ## Responsibilities
/// - Specify the View type corresponding to an enum case
/// - Allow the `@Screens` macro to read this attribute and generate a switch statement
public struct ScreenMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Do not generate any declarations as a peer macro
        // `@Screens` reads this attribute and performs the actual processing
        return []
    }
}

