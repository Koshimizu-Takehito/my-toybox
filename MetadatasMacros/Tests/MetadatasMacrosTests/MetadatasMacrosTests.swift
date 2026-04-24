import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(MetadatasMacrosImpl)
import MetadatasMacrosImpl

nonisolated(unsafe) private let metadatasMacros: [String: Macro.Type] = [
    "Metadatas": MetadatasMacro.self,
]

nonisolated(unsafe) private let metadataMacros: [String: Macro.Type] = [
    "Metadata": MetadataMacro.self,
]

/// Helper function to reduce boilerplate in @Metadatas macro expansion tests.
private func assertMetadatasMacroExpansion(
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
        macros: metadatasMacros,
        file: file,
        line: line
    )
}

/// Helper function to reduce boilerplate in @Metadata macro expansion tests.
private func assertMetadataMacroExpansion(
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
        macros: metadataMacros,
        file: file,
        line: line
    )
}
#else
/// Stub helper for when MetadatasMacrosImpl is not available.
private func assertMetadatasMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    // No-op when macro implementation is not available
}

/// Stub helper for when MetadatasMacrosImpl is not available.
private func assertMetadataMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    // No-op when macro implementation is not available
}
#endif

// MARK: - MetadatasMacrosTests

@Suite("MetadatasMacros Tests")
struct MetadatasMacrosTests {

    /// Ensures that metadata type is inferred from case name.
    @Test("Metadata type is inferred from case name")
    func metadatasMacroInfersType() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
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

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .gameOfLifeScreen:
                        GameOfLifeScreen()
                    case .mosaicScreen:
                        MosaicScreen()
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }

    /// Ensures that applying @Metadatas to a non-enum produces an error.
    @Test("Applying to non-enum produces a diagnostic error")
    func nonEnumProducesError() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
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
                    message: "@Metadatas can only be applied to an enum",
                    line: 1,
                    column: 1
                )
            ]
        )
    }

    /// Ensures that an empty enum generates an empty switch statement.
    @Test("Empty enum generates empty switch")
    func emptyEnumGeneratesEmptySwitch() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            enum EmptyScreenID {
            }
            """,
            expandedSource: """
            enum EmptyScreenID {
            }

            @MainActor
            extension EmptyScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }

    /// Ensures that a single-case enum works correctly.
    @Test("Single case enum works correctly")
    func singleCaseEnum() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            enum ScreenID {
                case onlyScreen
            }
            """,
            expandedSource: """
            enum ScreenID {
                case onlyScreen
            }

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .onlyScreen:
                        OnlyScreen()
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
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
        assertMetadatasMacroExpansion(
            """
            @Metadatas
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

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    case .detailScreen(id: let id):
                        DetailScreen(id: id)
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }

    /// Ensures that a case with multiple associated values generates proper pattern matching.
    @Test("Multiple associated values generate correct pattern")
    func multipleAssociatedValues() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            enum ScreenID {
                case userProfileScreen(userId: Int, showEdit: Bool)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case userProfileScreen(userId: Int, showEdit: Bool)
            }

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .userProfileScreen(userId: let userId, showEdit: let showEdit):
                        UserProfileScreen(userId: userId, showEdit: showEdit)
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }

    /// Ensures that unlabeled associated values are passed without labels.
    @Test("Unlabeled associated value is passed without label")
    func unlabeledAssociatedValue() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            enum ScreenID {
                case detailScreen(Int)
            }
            """,
            expandedSource: """
            enum ScreenID {
                case detailScreen(Int)
            }

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .detailScreen(let param0):
                        DetailScreen(param0)
                    }
                }

                var title: LocalizedStringResource {
                    metadata.title
                }

                var description: LocalizedStringResource {
                    metadata.description
                }

                var tags: [Tag] {
                    metadata.tags
                }

                var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }
}

// MARK: - Access Level Tests

@Suite("Access Level Tests")
struct AccessLevelTests {

    /// Ensures that public enums generate public properties.
    @Test("Public enum generates public properties")
    func publicEnumGeneratesPublicProperties() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            public enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            public enum ScreenID {
                case simpleScreen
            }

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                public var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }

                public var title: LocalizedStringResource {
                    metadata.title
                }

                public var description: LocalizedStringResource {
                    metadata.description
                }

                public var tags: [Tag] {
                    metadata.tags
                }

                public var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }

    /// Ensures that internal enums generate properties without explicit modifier.
    @Test("Internal enum generates properties without explicit modifier")
    func internalEnumGeneratesInternalProperties() {
        assertMetadatasMacroExpansion(
            """
            @Metadatas
            internal enum ScreenID {
                case simpleScreen
            }
            """,
            expandedSource: """
            internal enum ScreenID {
                case simpleScreen
            }

            @MainActor
            extension ScreenID: MetadatasMacros.Metadatas {
                internal var metadata: any MyToyboxCore.ScreenMetadata {
                    switch self {
                    case .simpleScreen:
                        SimpleScreen()
                    }
                }

                internal var title: LocalizedStringResource {
                    metadata.title
                }

                internal var description: LocalizedStringResource {
                    metadata.description
                }

                internal var tags: [Tag] {
                    metadata.tags
                }

                internal var thumbnail: AnyView {
                    func open(_ metadata: some MyToyboxCore.ScreenMetadata) -> AnyView {
                        AnyView(type(of: metadata).thumbnail)
                    }
                    return open(metadata)
                }
            }
            """
        )
    }
}

// MARK: - MetadataMacro Tests

@Suite("MetadataMacro Tests")
struct MetadataMacroTests {

    @Test("Basic expansion")
    func basicExpansion() {
        assertMetadataMacroExpansion(
            """
            @Metadata(title: "Test Screen", description: "A test", tags: [.animation])
            struct TestScreen: View {
                var body: some View { EmptyView() }
            }
            """,
            expandedSource: """
            struct TestScreen: View {
                var body: some View { EmptyView() }
            }

            extension TestScreen: @MainActor ScreenMetadata {
                var title: LocalizedStringResource {
                    LocalizedStringResource("Test Screen", bundle: .module)
                }
                var description: LocalizedStringResource {
                    LocalizedStringResource("A test", bundle: .module)
                }
                var tags: [Tag] {
                    [.animation]
                }
            }
            """
        )
    }

    @Test("Multiple tags")
    func multipleTags() {
        assertMetadataMacroExpansion(
            """
            @Metadata(title: "Multi Tag", description: "Multiple tags", tags: [.animation, .metal, .layout])
            struct MultiTagScreen: View {
                var body: some View { EmptyView() }
            }
            """,
            expandedSource: """
            struct MultiTagScreen: View {
                var body: some View { EmptyView() }
            }

            extension MultiTagScreen: @MainActor ScreenMetadata {
                var title: LocalizedStringResource {
                    LocalizedStringResource("Multi Tag", bundle: .module)
                }
                var description: LocalizedStringResource {
                    LocalizedStringResource("Multiple tags", bundle: .module)
                }
                var tags: [Tag] {
                    [.animation, .metal, .layout]
                }
            }
            """
        )
    }

    @Test("Empty tags")
    func emptyTags() {
        assertMetadataMacroExpansion(
            """
            @Metadata(title: "No Tags", description: "No tags", tags: [])
            struct NoTagScreen: View {
                var body: some View { EmptyView() }
            }
            """,
            expandedSource: """
            struct NoTagScreen: View {
                var body: some View { EmptyView() }
            }

            extension NoTagScreen: @MainActor ScreenMetadata {
                var title: LocalizedStringResource {
                    LocalizedStringResource("No Tags", bundle: .module)
                }
                var description: LocalizedStringResource {
                    LocalizedStringResource("No tags", bundle: .module)
                }
                var tags: [Tag] {
                    []
                }
            }
            """
        )
    }

    @Test("Public struct")
    func publicStruct() {
        assertMetadataMacroExpansion(
            """
            @Metadata(title: "Public", description: "Public screen", tags: [])
            public struct PublicScreen: View {
                public var body: some View { EmptyView() }
            }
            """,
            expandedSource: """
            public struct PublicScreen: View {
                public var body: some View { EmptyView() }
            }

            extension PublicScreen: @MainActor ScreenMetadata {
                public var title: LocalizedStringResource {
                    LocalizedStringResource("Public", bundle: .module)
                }
                public var description: LocalizedStringResource {
                    LocalizedStringResource("Public screen", bundle: .module)
                }
                public var tags: [Tag] {
                    []
                }
            }
            """
        )
    }

    @Test("Japanese text")
    func japaneseText() {
        assertMetadataMacroExpansion(
            """
            @Metadata(title: "ゲームオブライフ", description: "コンウェイのライフゲーム", tags: [.animation])
            struct GameOfLifeScreen: View {
                var body: some View { EmptyView() }
            }
            """,
            expandedSource: """
            struct GameOfLifeScreen: View {
                var body: some View { EmptyView() }
            }

            extension GameOfLifeScreen: @MainActor ScreenMetadata {
                var title: LocalizedStringResource {
                    LocalizedStringResource("ゲームオブライフ", bundle: .module)
                }
                var description: LocalizedStringResource {
                    LocalizedStringResource("コンウェイのライフゲーム", bundle: .module)
                }
                var tags: [Tag] {
                    [.animation]
                }
            }
            """
        )
    }
}
