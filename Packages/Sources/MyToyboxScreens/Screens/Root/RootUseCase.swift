import Foundation

// MARK: - RootUseCase

/// A simple use case that loads `Screen` data from a bundled JSON file named `Screens.json`.
///
/// This runs in an actor to ensure safe concurrency.
actor RootUseCase {
    private(set) var screens: [Screen] = []

    /// Loads and decodes the list of available screen IDs from the bundle.
    func fetchScreen() throws -> [Screen] {
        if !screens.isEmpty {
            return screens
        }
        guard let url = Bundle.module.url(forResource: "Screens", withExtension: "json") else {
            return []
        }
        let screens = try JSONDecoder().decode([Screen].self, from: Data(contentsOf: url))
        self.screens = screens
        return screens
    }
}
