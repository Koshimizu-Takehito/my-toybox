import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(ScreenMacrosImpl)
import ScreenMacrosImpl

private let testMacros: [String: Macro.Type] = [
    "ScreenRegistry": ScreenRegistryMacro.self,
    "Screen": ScreenMacro.self,
]
#endif

// MARK: - ScreenMacrosTests

@Suite("ScreenMacros Tests")
struct ScreenMacrosTests {

    /// Ensures that even cases without an explicit @Screen attribute infer the View type from the case name.
    @Test("View type is inferred from case name")
    func screenRegistryMacroInfersViewType() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID: String {
                case gameOfLifeScreen
                case mosaicScreen
            }
            """,
            expandedSource: """
            enum ScreenID: String {
                case gameOfLifeScreen
                case mosaicScreen
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .gameOfLifeScreen:
                        GameOfLifeScreen()
                    case .mosaicScreen:
                        MosaicScreen()
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that an explicitly specified type via @Screen is honored.
    @Test("Explicit @Screen type is used when specified")
    func screenRegistryMacroWithExplicitType() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID: String {
                case inferredScreen
                @Screen(CustomView.self)
                case customScreen
            }
            """,
            expandedSource: """
            enum ScreenID: String {
                case inferredScreen
                case customScreen
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .inferredScreen:
                        InferredScreen()
                    case .customScreen:
                        CustomView()
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that @Screen without arguments behaves the same as having no @Screen.
    @Test("@Screen without arguments works the same as no @Screen")
    func screenRegistryMacroWithScreenAttributeNoArgs() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID: String {
                @Screen
                case explicitScreen
                case implicitScreen
            }
            """,
            expandedSource: """
            enum ScreenID: String {
                case explicitScreen
                case implicitScreen
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .explicitScreen:
                        ExplicitScreen()
                    case .implicitScreen:
                        ImplicitScreen()
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that cases with associated values produce an error.
    @Test("Associated value cases produce a diagnostic error")
    func associatedValueCaseProducesError() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID: String {
                case normalScreen
                case invalidScreen(value: Int)
            }
            """,
            expandedSource: """
            enum ScreenID: String {
                case normalScreen
                case invalidScreen(value: Int)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ScreenRegistry does not support enum cases with associated values (case: invalidScreen)",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #endif
    }

    /// Ensures that applying @ScreenRegistry to a non-enum produces an error.
    @Test("Applying to non-enum produces a diagnostic error")
    func nonEnumProducesError() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            struct NotAnEnum {
                var value: Int
            }
            """,
            expandedSource: """
            struct NotAnEnum {
                var value: Int
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ScreenRegistry can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #endif
    }
}
