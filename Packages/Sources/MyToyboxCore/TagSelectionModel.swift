import Observation
import SwiftUI

// MARK: - TagSelectionModel

/// A view model that manages the selection state of all available tags.
///
/// - Automatically observable via the `@Observable` macro so SwiftUI views
///   can bind to its `selections` array and react to changes.
/// - Provides convenience methods to select or deselect all tags at once.
@Observable
public final class TagSelectionModel {
    /// An array of `Selection` values—one per tag—tracking which tags are selected.
    public var selections: [Selection] = .init(initialSelectionState: false)

    /// The list of tags that are currently selected.
    public var selected: [Tag] {
        selections.filter(\.isSelected).map(\.tag)
    }

    public init() {}

    /// Marks every tag as selected.
    public func selectAll() {
        selections = .init(initialSelectionState: true)
    }

    /// Marks every tag as deselected.
    public func deselectAll() {
        selections = .init(initialSelectionState: false)
    }
}

// MARK: TagSelectionModel.Selection

public extension TagSelectionModel {
    /// Represents a single tag's selection state.
    struct Selection: Hashable {
        /// The tag being represented.
        public var tag: Tag

        /// Whether this tag is currently selected.
        public var isSelected: Bool

        /// The display color associated with this tag.
        public var color: Color { tag.color }
    }
}

// MARK: - TagSelectionModel.Selection + Identifiable

extension TagSelectionModel.Selection: Identifiable {
    /// Use the underlying `Tag` as the identifier.
    public var id: Tag { tag }
}

// MARK: - Array<Selection> Convenience Initializer

private extension [TagSelectionModel.Selection] {
    /// Creates a `Selection` for each tag in `Tag.allCases`, all initialized
    /// to the same selection state.
    ///
    /// - Parameter initialSelectionState: The Boolean value to assign
    ///   to each `Selection.isSelected`.
    init(initialSelectionState: Bool) {
        self = Tag.allCases.map { tag in
            .init(tag: tag, isSelected: initialSelectionState)
        }
    }
}
