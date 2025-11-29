import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(ScreenMacrosImpl)
import ScreenMacrosImpl

private let testMacros: [String: Macro.Type] = [
    "Screens": ScreensMacro.self,
    "Screen": ScreenMacro.self,
]

/// Helper function to reduce boilerplate in macro expansion tests.
///
/// This wrapper handles the common pattern of calling `assertMacroExpansion`
/// with the standard test macros, reducing code duplication across tests.
///
/// - Parameters:
///   - originalSource: The source code before macro expansion.
///   - expandedSource: The expected source code after macro expansion.
///   - diagnostics: Expected diagnostic messages (errors, warnings).
///   - file: The file where the test is defined (for error reporting).
///   - line: The line where the test is defined (for error reporting).
private func assertScreenMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    assertMacroExpansion(
        originalSource,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macros: testMacros,
        file: file,
        line: line
    )
}
#else
/// Stub helper for when ScreenMacrosImpl is not available.
private func assertScreenMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    // No-op when macro implementation is not available
}
#endif

// MARK: - ScreenMacrosTests

@Suite("ScreenMacros Tests")
struct ScreenMacrosTests {

    /// Ensures that even cases without an explicit @Screen attribute infer the View type from the case name.
    @Test("View type is inferred from case name")
    func screensMacroInfersViewType() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .gameOfLifeScreen:
                        GameOfLifeScreen()
                    case .mosaicScreen:
                        MosaicScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that an explicitly specified type via @Screen is honored.
    @Test("Explicit @Screen type is used when specified")
    func screensMacroWithExplicitType() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .inferredScreen:
                        InferredScreen()
                    case .customScreen:
                        CustomView()
                    }
                }
            }
            """
        )
    }

    /// Ensures that @Screen without arguments behaves the same as having no @Screen.
    @Test("@Screen without arguments works the same as no @Screen")
    func screensMacroWithScreenAttributeNoArgs() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .explicitScreen:
                        ExplicitScreen()
                    case .implicitScreen:
                        ImplicitScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that applying @Screens to a non-enum produces an error.
    @Test("Applying to non-enum produces a diagnostic error")
    func nonEnumProducesError() {
        assertScreenMacroExpansion(
            """
            @Screens
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
                    message: "@Screens can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ]
        )
    }

    /// Ensures that applying @Screens to a class produces an error.
    @Test("Applying to class produces a diagnostic error")
    func classProducesError() {
        assertScreenMacroExpansion(
            """
            @Screens
            class NotAnEnum {
                var value: Int = 0
            }
            """,
            expandedSource: """
            class NotAnEnum {
                var value: Int = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Screens can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ]
        )
    }

    /// Ensures that an empty enum generates an empty switch statement.
    @Test("Empty enum generates empty switch")
    func emptyEnumGeneratesEmptySwitch() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum EmptyScreenID {
            }
            """,
            expandedSource: """
            enum EmptyScreenID {
            }

            extension EmptyScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    }
                }
            }
            """
        )
    }

    /// Ensures that a single-case enum works correctly.
    @Test("Single case enum works correctly")
    func singleCaseEnum() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                case onlyScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case onlyScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .onlyScreen:
                        OnlyScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that @Screen without .self suffix works correctly.
    @Test("@Screen type without .self suffix")
    func screenTypeWithoutSelfSuffix() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(CustomView)
                case customScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case customScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .customScreen:
                        CustomView()
                    }
                }
            }
            """
        )
    }
}

// MARK: - Associated Value Tests

@Suite("Associated Value Tests")
struct AssociatedValueTests {

    /// Ensures that a case with a single associated value generates proper pattern matching.
    @Test("Single associated value generates correct pattern")
    func singleAssociatedValue() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    case .detailScreen(id: let id):
                        DetailScreen(id: id)
                    }
                }
            }
            """
        )
    }

    /// Ensures that a case with multiple associated values generates proper pattern matching.
    @Test("Multiple associated values generate correct pattern")
    func multipleAssociatedValues() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    case .userProfileScreen(userId: let userId, showEdit: let showEdit):
                        UserProfileScreen(userId: userId, showEdit: showEdit)
                    }
                }
            }
            """
        )
    }

    /// Ensures that associated values work with explicit @Screen type.
    @Test("Associated values with explicit @Screen type")
    func associatedValueWithExplicitType() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(CustomDetailView.self)
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        CustomDetailView(id: id)
                    }
                }
            }
            """
        )
    }

    /// Ensures that mixed cases (with and without associated values) work correctly.
    @Test("Mixed cases with and without associated values")
    func mixedCases() {
        assertScreenMacroExpansion(
            """
            @Screens
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

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
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
            """
        )
    }

    /// Ensures that unlabeled associated values generate proper pattern matching.
    @Test("Unlabeled associated value generates param0, param1, etc.")
    func unlabeledAssociatedValue() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                case detailScreen(Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(let param0):
                        DetailScreen(param0: param0)
                    }
                }
            }
            """
        )
    }

    /// Ensures that mixed labeled and unlabeled associated values work correctly.
    @Test("Mixed labeled and unlabeled associated values")
    func mixedLabeledAndUnlabeledAssociatedValues() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                case mixedScreen(Int, name: String)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case mixedScreen(Int, name: String)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .mixedScreen(let param0, name: let name):
                        MixedScreen(param0: param0, name: name)
                    }
                }
            }
            """
        )
    }
}

// MARK: - Parameter Mapping Tests

@Suite("Parameter Mapping Tests")
struct ParameterMappingTests {

    /// Ensures that parameter mapping remaps a single parameter.
    @Test("Single parameter mapping")
    func singleParameterMapping() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(DetailView.self, ["id": "detailId"])
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        DetailView(detailId: id)
                    }
                }
            }
            """
        )
    }

    /// Ensures that parameter mapping remaps multiple parameters.
    @Test("Multiple parameter mapping")
    func multipleParameterMapping() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(ProfileView.self, ["userId": "id", "showEdit": "editable"])
                case profileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case profileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .profileScreen(userId: let userId, showEdit: let showEdit):
                        ProfileView(id: userId, editable: showEdit)
                    }
                }
            }
            """
        )
    }

    /// Ensures that partial mapping works (only some parameters are remapped).
    @Test("Partial parameter mapping")
    func partialParameterMapping() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(ProfileView.self, ["userId": "id"])
                case profileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case profileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .profileScreen(userId: let userId, showEdit: let showEdit):
                        ProfileView(id: userId, showEdit: showEdit)
                    }
                }
            }
            """
        )
    }

    /// Ensures that empty mapping dictionary is treated as no mapping.
    @Test("Empty mapping dictionary")
    func emptyMappingDictionary() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(DetailView.self, [:])
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        DetailView(id: id)
                    }
                }
            }
            """
        )
    }

    /// Ensures that mapping-only @Screen (without View type) works correctly.
    @Test("Mapping only without View type")
    func mappingOnlyWithoutViewType() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(["foo": "image"])
                case multiColorImage(foo: Image, colors: [Color])
            }
            """,
            expandedSource: """
            enum ScreenID {
                case multiColorImage(foo: Image, colors: [Color])
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .multiColorImage(foo: let foo, colors: let colors):
                        MultiColorImage(image: foo, colors: colors)
                    }
                }
            }
            """
        )
    }

    /// Ensures that mapping-only @Screen works with multiple remapped parameters.
    @Test("Mapping only with multiple remapped parameters")
    func mappingOnlyMultipleParams() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(["userId": "id", "showEdit": "editable"])
                case userProfileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case userProfileScreen(userId: Int, showEdit: Bool)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .userProfileScreen(userId: let userId, showEdit: let showEdit):
                        UserProfileScreen(id: userId, editable: showEdit)
                    }
                }
            }
            """
        )
    }
}

// MARK: - Generics and Module Qualifier Tests

@Suite("Generics and Module Qualifier Tests")
struct GenericsAndModuleQualifierTests {

    /// Ensures that module-qualified types are correctly parsed.
    @Test("Module-qualified type")
    func moduleQualifiedType() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(SomeModule.CustomView.self)
                case customScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case customScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .customScreen:
                        SomeModule.CustomView()
                    }
                }
            }
            """
        )
    }

    /// Ensures that generic types with single type parameter are correctly parsed.
    @Test("Generic type with single parameter")
    func genericTypeSingleParameter() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(GenericView<Int>.self)
                case genericScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case genericScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .genericScreen:
                        GenericView<Int>()
                    }
                }
            }
            """
        )
    }

    /// Ensures that generic types with multiple type parameters are correctly parsed.
    @Test("Generic type with multiple parameters")
    func genericTypeMultipleParameters() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(GenericView<Int, String>.self)
                case genericScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case genericScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .genericScreen:
                        GenericView<Int, String>()
                    }
                }
            }
            """
        )
    }

    /// Ensures that module-qualified generic types are correctly parsed.
    @Test("Module-qualified generic type")
    func moduleQualifiedGenericType() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(SomeModule.GenericView<Int>.self)
                case fullyQualifiedScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case fullyQualifiedScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .fullyQualifiedScreen:
                        SomeModule.GenericView<Int>()
                    }
                }
            }
            """
        )
    }

    /// Ensures that deeply nested module types work correctly.
    @Test("Deeply nested module type")
    func deeplyNestedModuleType() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(Module.SubModule.DeepView.self)
                case deepScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case deepScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .deepScreen:
                        Module.SubModule.DeepView()
                    }
                }
            }
            """
        )
    }

    /// Ensures that generic types with associated values and parameter mapping work correctly.
    @Test("Generic type with associated values and mapping")
    func genericTypeWithAssociatedValuesAndMapping() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(GenericDetailView<Int>.self, ["itemId": "id"])
                case detailScreen(itemId: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(itemId: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(itemId: let itemId):
                        GenericDetailView<Int>(id: itemId)
                    }
                }
            }
            """
        )
    }

    /// Ensures that complex generic types (e.g., Array<String>) work correctly.
    @Test("Complex generic type parameter")
    func complexGenericTypeParameter() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(ListView<[String]>.self)
                case listScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case listScreen
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .listScreen:
                        ListView<[String]>()
                    }
                }
            }
            """
        )
    }
}

// MARK: - Access Level Tests

@Suite("Access Level Tests")
struct AccessLevelTests {

    /// Ensures that public enums generate public extensions and public body properties.
    @Test("Public enum generates public extension and public body")
    func publicEnumGeneratesPublicAPI() {
        assertScreenMacroExpansion(
            """
            @Screens
            public enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            public enum ScreenID {
                case simpleScreen
            }

            public extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                public var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that internal enums (default) generate internal extensions without explicit modifier.
    @Test("Internal enum generates extension without explicit modifier")
    func internalEnumGeneratesInternalAPI() {
        assertScreenMacroExpansion(
            """
            @Screens
            internal enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            internal enum ScreenID {
                case simpleScreen
            }

            internal extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                internal var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that fileprivate enums generate fileprivate extensions.
    @Test("Fileprivate enum generates fileprivate extension")
    func fileprivateEnumGeneratesFileprivateAPI() {
        assertScreenMacroExpansion(
            """
            @Screens
            fileprivate enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            fileprivate enum ScreenID {
                case simpleScreen
            }

            fileprivate extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                fileprivate var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }
            }
            """
        )
    }

    /// Ensures that private enums generate private extensions.
    @Test("Private enum generates private extension")
    func privateEnumGeneratesPrivateAPI() {
        assertScreenMacroExpansion(
            """
            @Screens
            private enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            private enum ScreenID {
                case simpleScreen
            }

            private extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                private var body: some View {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }
            }
            """
        )
    }
}

// MARK: - Optional and Result Associated Values Tests

@Suite("Optional and Result Associated Values Tests")
struct OptionalAndResultAssociatedValuesTests {

    /// Ensures that Optional associated values are correctly passed through to the View initializer.
    @Test("Optional associated value")
    func optionalAssociatedValue() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                case optionalDetail(id: Int?)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case optionalDetail(id: Int?)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .optionalDetail(id: let id):
                        OptionalDetail(id: id)
                    }
                }
            }
            """
        )
    }

    /// Ensures that Result associated values are correctly passed through to the View initializer.
    @Test("Result associated value")
    func resultAssociatedValue() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                case loadResult(result: Result<Int, Error>)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case loadResult(result: Result<Int, Error>)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .loadResult(result: let result):
                        LoadResult(result: result)
                    }
                }
            }
            """
        )
    }
}

// MARK: - Error Handling Tests

@Suite("Error Handling Tests")
struct ErrorHandlingTests {

    /// Ensures that an invalid second argument (non-dictionary) produces an error.
    @Test("Invalid mapping argument produces error")
    func invalidMappingArgumentProducesError() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(DetailView.self, "notADictionary")
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Screen's second argument must be a dictionary literal (e.g., [\"id\": \"detailId\"])",
                    line: 3,
                    column: 5
                )
            ]
        )
    }

    /// Ensures that unused mapping keys produce a warning.
    @Test("Unused mapping keys produce warning")
    func unusedMappingKeysProduceWarning() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(DetailView.self, ["typoId": "detailId", "id": "correctId"])
                case detailScreen(id: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(id: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .detailScreen(id: let id):
                        DetailView(correctId: id)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Mapping keys [\"typoId\"] do not match any parameter labels in case 'detailScreen' and will be ignored",
                    line: 3,
                    column: 5,
                    severity: .warning
                )
            ]
        )
    }

    /// Ensures that multiple unused mapping keys are reported in a single warning.
    @Test("Multiple unused mapping keys produce single warning")
    func multipleUnusedMappingKeys() {
        assertScreenMacroExpansion(
            """
            @Screens
            enum ScreenID {
                @Screen(ProfileView.self, ["unknownKey1": "a", "unknownKey2": "b"])
                case profileScreen(userId: Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case profileScreen(userId: Int)
            }

            extension ScreenID: View, ScreenMacros.Screens {
                @MainActor @ViewBuilder
                var body: some View {
                    switch self {
                    case .profileScreen(userId: let userId):
                        ProfileView(userId: userId)
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Mapping keys [\"unknownKey1\", \"unknownKey2\"] do not match any parameter labels in case 'profileScreen' and will be ignored",
                    line: 3,
                    column: 5,
                    severity: .warning
                )
            ]
        )
    }
}
