// MARK: - Metadatas Protocol

/// Marker protocol used by `@Metadatas` macro for conformance declaration.
///
/// This protocol serves as a placeholder for the macro's conformance declaration.
/// The actual protocol used in generated code is `ScreenMetadata` from MyToyboxCore.
public protocol Metadatas {}

// MARK: - @Metadatas Macro

/// Macro that generates `ScreenMetadata` protocol conformance for an enum.
///
/// When applied to an enum, this macro generates an extension that:
/// 1. Conforms to `ScreenMetadata` protocol
/// 2. Provides a `metadata` property that returns the corresponding View instance
/// 3. Provides `title`, `description`, and `tags` properties that delegate to `metadata`
///
/// ## Example
///
/// ```swift
/// @Metadatas
/// enum ScreenID: String {
///     case gameOfLifeScreen
///     case mosaicScreen
/// }
/// ```
///
/// ## Generated Extension
///
/// ```swift
/// extension ScreenID: ScreenMetadata {
///     var metadata: any ScreenMetadata {
///         switch self {
///         case .gameOfLifeScreen: GameOfLifeScreen()
///         case .mosaicScreen: MosaicScreen()
///         }
///     }
///     var title: String { metadata.title }
///     var description: String { metadata.description }
///     var tags: [Tag] { metadata.tags }
/// }
/// ```
///
/// The View type is inferred from the case name by converting it to UpperCamelCase.
/// Each View must conform to `ScreenMetadata` protocol (typically via `@Metadata` macro).
@attached(extension, conformances: Metadatas, names: named(metadata), named(title), named(description), named(tags), named(thumbnail))
public macro Metadatas() = #externalMacro(
    module: "MetadatasMacrosImpl",
    type: "MetadatasMacro"
)

// MARK: - @Metadata Macro

/// Macro that generates `ScreenMetadata` protocol conformance for a View.
///
/// ## Example
///
/// ```swift
/// @Metadata(
///     title: "Game Of Life",
///     description: "Conway's Game of Life simulation",
///     tags: [.animation, .metal]
/// )
/// struct GameOfLifeScreen: View {
///     var body: some View { ... }
/// }
/// ```
///
/// ## Generated Extension
///
/// ```swift
/// extension GameOfLifeScreen: @MainActor ScreenMetadata {
///     var title: String { "Game Of Life" }
///     var description: String { "Conway's Game of Life simulation" }
///     var tags: [Tag] { [.animation, .metal] }
/// }
/// ```
///
/// - Parameters:
///   - title: The display title for this screen.
///   - description: A brief description of the screen's functionality.
///   - tags: An array of Tag values categorizing this screen.
@attached(extension, names: named(title), named(description), named(tags))
public macro Metadata<T>(
    title: String,
    description: String,
    tags: [T]
) = #externalMacro(module: "MetadatasMacrosImpl", type: "MetadataMacro")
