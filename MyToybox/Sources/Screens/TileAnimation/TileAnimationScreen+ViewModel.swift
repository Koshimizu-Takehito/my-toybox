import Foundation
import Observation

extension TileAnimationScreen {
    // MARK: - Model
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var rotations: [[Int]]
        private(set) var row: Int
        private(set) var column: Int

        init(row: Int, column: Int) {
            self.row = row
            self.column = column
            self.rotations = (0..<row).map { _ in
                (0..<column).map { _ in
                    Int.random(in: 0..<4)
                }
            }
        }

        func rotate() {
            rotations.lazy
                .enumerated()
                .flatMap { xx in
                    xx.element.lazy.enumerated().map { x in
                        (i: xx.offset, j: x.offset)
                    }
                }
                .shuffled()
                .prefix(2 * rotations.count)
                .forEach { i, j in
                    rotations[i][j] += i.isMultiple(of: 2) ? 1 : -1
                }
        }
    }
}
