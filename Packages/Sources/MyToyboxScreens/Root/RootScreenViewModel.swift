import Foundation
import MyToyboxCore
import Observation

// MARK: - RootScreenViewModel

/// A view model that loads, holds, and filters the list of available screens for display.
///
/// - Loads screen metadata via `ScreenUseCase` from a local JSON file.
/// - Filters screens based on the currently selected tags in `tags`.
@Observable
@MainActor
final class RootScreenViewModel {
    /// The model managing tag selection state.
    let tags = TagSelectionModel()

    /// The use case responsible for fetching screen data.
    private let screenUseCase = ScreenUseCase()

    /// The list of screens fetched from the JSON file.
    private(set) var screens: [Screen] = []

    /// Fetches available screens asynchronously and stores the result.
    func fetch() async {
        do {
            screens = try await screenUseCase.fetch()
        } catch {
            print(error)
        }
    }

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
