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
    private let useCase = ScreenUseCase()

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
