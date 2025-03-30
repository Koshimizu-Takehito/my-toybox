import Foundation
import Observation

// MARK: - RootScreenViewModel

/// A view model that loads and holds the list of available screens for display.
///
/// Uses `RootScreenUseCase` to read a local JSON file containing metadata about each screen.
@Observable
@MainActor
final class RootScreenViewModel {
    /// The use case responsible for fetching screen data.
    private let useCase = RootScreenUseCase()

    /// The list of screens fetched from the JSON file.
    private(set) var screens: [Screen] = []

    /// Fetches available screens asynchronously and stores the result.
    func fetch() async {
        do {
            screens = try await useCase.fetch()
        } catch {
            print(error)
        }
    }
}

// MARK: - RootScreenUseCase

/// A simple use case that loads `Screen` data from a bundled JSON file named `Screens.json`.
///
/// This runs in an actor to ensure safe concurrency.
actor RootScreenUseCase {
    /// Loads and decodes the list of available screens from the bundle.
    func fetch() async throws -> [Screen] {
        guard let url = Bundle.main.url(forResource: "Screens", withExtension: "json") else {
            return []
        }
        return try JSONDecoder().decode([Screen].self, from: Data(contentsOf: url))
    }
}
