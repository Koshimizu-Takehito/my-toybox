import SwiftUI

// MARK: - MyToyboxScreen

/// A screen that can appear in the app gallery.
///
/// Conforming types are `String`-raw-value enums whose cases each map
/// to a SwiftUI `View`, a set of `ScreenMetadata` (title, description, tags),
/// and a thumbnail preview. The `@Screens` and `@Metadatas` macros generate
/// the required implementations automatically.
public protocol MyToyboxScreen<RawValue, AllCases, ID>: View, RawRepresentable, CaseIterable, Hashable, Identifiable, Sendable, ScreenMetadata
    where AllCases == [Self], RawValue == String
{
    /// The stable identifier derived from the enum case's raw value.
    var id: ID { get }

    /// A type-erased thumbnail view used in list cells.
    var thumbnail: AnyView { get }
}

public extension MyToyboxScreen where RawValue == String, ID == RawValue {
    nonisolated var id: String { rawValue }
}
