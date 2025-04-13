import Foundation

// MARK: - ScreenUseCase

/// A simple use case that loads `Screen` data from a bundled JSON file named `Screens.json`.
///
/// This runs in an actor to ensure safe concurrency.
actor ScreenUseCase {
    /// Loads and decodes the list of available screens from the bundle.
    func fetch() async throws -> [Screen] {
        guard let url = Bundle.main.url(forResource: "Screens", withExtension: "json") else {
            return []
        }
        return try JSONDecoder().decode([Screen].self, from: Data(contentsOf: url))
    }
}
