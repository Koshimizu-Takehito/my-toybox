import Foundation
import MyToyboxCore
import Observation

// MARK: - RootScreenModel

/// A view model that loads, holds, and filters the list of available screens for display.
///
/// - Loads screen metadata via `RootUseCase` from the `Screen` enum.
/// - Filters screens based on the currently selected tags in `tags`.
@Observable
@MainActor
final class RootScreenModel<Screen: MyToyboxScreen> {
    /// The model managing tag selection state.
    let tags = TagSelectionModel()

    /// The list of screens fetched from the `Screen` enum.
    let screens: [Screen] = Screen.allCases

    init() {}

    /// Returns screens that match any of the selected tags.
    ///
    /// - If no tags are selected, returns all screens.
    func filteredScreens() -> [Screen] {
        // Build a set of selected tags
        let selectedTags = Set(tags.selections.filter(\.isSelected).map(\.tag))
        // Return all if no selection
        guard !selectedTags.isEmpty else {
            return screens
        }
        // Return screens where tags intersect
        return screens.filter { screen in
            !selectedTags.isDisjoint(with: screen.tags)
        }
    }
}
