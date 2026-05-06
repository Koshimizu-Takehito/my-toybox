import Foundation
import MetadatasMacros
import SwiftUI

/// Generates a `ScreenMetadata` conformance for the annotated enum case or type.
///
/// Apply this macro to a `Screen` enum case to synthesize the `title`, `description`,
/// and `tags` properties required by ``ScreenMetadata`` without boilerplate.
/// The `@Metadatas` macro collects all `@Metadata` annotations in the enum and
/// dispatches to the per-case implementations generated here.
@attached(extension, conformances: ScreenMetadata, names: named(title), named(description), named(tags))
public macro Metadata(
    title: LocalizedStringResource,
    description: LocalizedStringResource,
    tags: [Tag]
) = #externalMacro(module: "MetadatasMacrosImpl", type: "MetadataMacro")

// MARK: - ScreenMetadata

/// Protocol that provides metadata for a screen.
@MainActor
public protocol ScreenMetadata {
    associatedtype ThumbnailContent: View

    /// The display title of the screen.
    var title: LocalizedStringResource { get }

    /// A short description of what the screen shows or does.
    var description: LocalizedStringResource { get }

    /// Tags categorizing this screen.
    var tags: [Tag] { get }

    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> ThumbnailContent
}

public extension ScreenMetadata {
    static var thumbnail: some View {
        ThumbnailView(content: thumbnail(isScrolling:time:))
    }

    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {}
}
