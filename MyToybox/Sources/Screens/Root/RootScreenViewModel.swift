import Foundation
import Observation

@Observable
@MainActor
final class RootScreenViewModel {
    private let useCase = RootScreenUseCase()
    private(set) var screens: [Screen] = []

    func fetch() async {
        do {
            screens = try await useCase.fetch()
        } catch {
            print(error)
        }
    }
}

actor RootScreenUseCase {
    func fetch() async throws -> [Screen] {
        guard let url = Bundle.main.url(forResource: "Screens", withExtension: "json") else {
            return []
        }
        return try JSONDecoder().decode([Screen].self, from: Data(contentsOf: url))
    }
}
