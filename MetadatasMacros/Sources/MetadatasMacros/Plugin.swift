import SwiftCompilerPlugin
import SwiftSyntaxMacros

// MARK: - MetadatasMacrosPlugin

/// Macro plugin provided to the Swift compiler.
@main
struct MetadatasMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MetadatasMacro.self,
        MetadataMacro.self,
    ]
}
