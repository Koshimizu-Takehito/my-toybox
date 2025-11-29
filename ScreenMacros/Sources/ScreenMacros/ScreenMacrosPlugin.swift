import SwiftCompilerPlugin
import SwiftSyntaxMacros

// MARK: - ScreenMacrosPlugin

/// Macro plugin provided to the Swift compiler.
@main
struct ScreenMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ScreenMacro.self,
        ScreensMacro.self,
    ]
}

