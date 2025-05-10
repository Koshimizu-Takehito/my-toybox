import Foundation
import Observation

@Observable
@MainActor
final class HomeIconModel {
    private let repository = HomeIconRepository()
    var items: [[HomeIcon]] = []
    var numberOfColumn: Int

    init(numberOfColumn: Int) {
        self.numberOfColumn = numberOfColumn
        Task { [weak self] in
            await self?.fetch()
        }
    }

    private func fetch() async {
        self.items = await repository
            .fetch(numberOfChunk: numberOfColumn)
    }
}
