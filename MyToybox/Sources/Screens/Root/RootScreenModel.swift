import Foundation
import Observation

@Observable
@MainActor
final class RootScreenModel {
    private(set) var screens: [Screen] = []

    func fetch() async {
        Task.detached {
            guard let url = Bundle.main.url(forResource: "Screens", withExtension: "json") else {
                return
            }
            do {
                let screens = try JSONDecoder().decode([Screen].self, from: Data(contentsOf: url))
                Task { @MainActor in
                    self.screens = screens
                }
            } catch {
                print(error)
            }
        }
    }
}
