import Observation
import SwiftUI

// MARK: - TagSelectionModel

/// A view model that manages the selection state of all available tags.
///
/// - Automatically observable via the `@Observable` macro so SwiftUI views
///   can bind to its `selections` array and react to changes.
/// - Provides convenience methods to select or deselect all tags at once.
@Observable
final class TagSelectionModel {
    /// An array of `Selection` values—one per tag—tracking which tags are selected.
    var selections: [Selection] = .init(initialSelectionState: false)

    /// The list of tags that are currently selected.
    var selected: [Tag] {
        selections.filter(\.isSelected).map(\.tag)
    }

    /// Marks every tag as selected.
    func selectAll() {
        selections = .init(initialSelectionState: true)
    }

    /// Marks every tag as deselected.
    func deselectAll() {
        selections = .init(initialSelectionState: false)
    }
}

// MARK: - TagSelectionModel.Selection

extension TagSelectionModel {
    /// Represents a single tag’s selection state.
    struct Selection: Hashable {
        /// The tag being represented.
        var tag: Tag

        /// Whether this tag is currently selected.
        var isSelected: Bool

        /// The display color associated with this tag.
        var color: Color { tag.color }
    }
}

// MARK: - Identifiable Conformance

extension TagSelectionModel.Selection: Identifiable {
    /// Use the underlying `Tag` as the identifier.
    var id: Tag { tag }
}

// MARK: - Array<Selection> Convenience Initializer

extension Array where Element == TagSelectionModel.Selection {
    /// Creates a `Selection` for each tag in `Tag.allCases`, all initialized
    /// to the same selection state.
    ///
    /// - Parameter initialSelectionState: The Boolean value to assign
    ///   to each `Selection.isSelected`.
    fileprivate init(initialSelectionState: Bool) {
        self = Tag.allCases.map { tag in
            .init(tag: tag, isSelected: initialSelectionState)
        }
    }
}
