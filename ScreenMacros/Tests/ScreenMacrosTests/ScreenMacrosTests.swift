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

// MARK: - Associated Value Tests

@Suite("Associated Value Tests")
struct AssociatedValueTests {

    /// Ensures that a case with a single associated value generates proper pattern matching.
    @Test("Single associated value generates correct pattern")
    func singleAssociatedValue() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                case simpleScreen
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case simpleScreen
                case detailScreen(id: Int)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    case .detailScreen(id: let id):
                        DetailScreen(id: id)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that a case with multiple associated values generates proper pattern matching.
    @Test("Multiple associated values generate correct pattern")
    func multipleAssociatedValues() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                case simpleScreen
                case userProfileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case simpleScreen
                case userProfileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    case .userProfileScreen(userId: let userId, showEdit: let showEdit):
                        UserProfileScreen(userId: userId, showEdit: showEdit)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that associated values work with explicit @Screen type.
    @Test("Associated values with explicit @Screen type")
    func associatedValueWithExplicitType() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(CustomDetailView.self)
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        CustomDetailView(id: id)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that mixed cases (with and without associated values) work correctly.
    @Test("Mixed cases with and without associated values")
    func mixedCases() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                case homeScreen
                case detailScreen(id: Int)
                case settingsScreen
                case profileScreen(userId: String, editable: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case homeScreen
                case detailScreen(id: Int)
                case settingsScreen
                case profileScreen(userId: String, editable: Bool)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .homeScreen:
                        HomeScreen()
                    case .detailScreen(id: let id):
                        DetailScreen(id: id)
                    case .settingsScreen:
                        SettingsScreen()
                    case .profileScreen(userId: let userId, editable: let editable):
                        ProfileScreen(userId: userId, editable: editable)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}

// MARK: - Parameter Mapping Tests

@Suite("Parameter Mapping Tests")
struct ParameterMappingTests {

    /// Ensures that parameter mapping remaps a single parameter.
    @Test("Single parameter mapping")
    func singleParameterMapping() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(DetailView.self, ["id": "detailId"])
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        DetailView(detailId: id)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that parameter mapping remaps multiple parameters.
    @Test("Multiple parameter mapping")
    func multipleParameterMapping() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(ProfileView.self, ["userId": "id", "showEdit": "editable"])
                case profileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case profileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .profileScreen(userId: let userId, showEdit: let showEdit):
                        ProfileView(id: userId, editable: showEdit)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that partial mapping works (only some parameters are remapped).
    @Test("Partial parameter mapping")
    func partialParameterMapping() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(ProfileView.self, ["userId": "id"])
                case profileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case profileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .profileScreen(userId: let userId, showEdit: let showEdit):
                        ProfileView(id: userId, showEdit: showEdit)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that empty mapping dictionary is treated as no mapping.
    @Test("Empty mapping dictionary")
    func emptyMappingDictionary() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(DetailView.self, [:])
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        DetailView(id: id)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that mapping-only @Screen (without View type) works correctly.
    @Test("Mapping only without View type")
    func mappingOnlyWithoutViewType() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(["foo": "image"])
                case multiColorImage(foo: Image, colors: [Color])
            }
            """,
            expandedSource: """
            enum ScreenID {
                case multiColorImage(foo: Image, colors: [Color])
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .multiColorImage(foo: let foo, colors: let colors):
                        MultiColorImage(image: foo, colors: colors)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    /// Ensures that mapping-only @Screen works with multiple remapped parameters.
    @Test("Mapping only with multiple remapped parameters")
    func mappingOnlyMultipleParams() {
        #if canImport(ScreenMacrosImpl)
        assertMacroExpansion(
            """
            @ScreenRegistry
            enum ScreenID {
                @Screen(["userId": "id", "showEdit": "editable"])
                case userProfileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case userProfileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .userProfileScreen(userId: let userId, showEdit: let showEdit):
                        UserProfileScreen(id: userId, editable: showEdit)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
