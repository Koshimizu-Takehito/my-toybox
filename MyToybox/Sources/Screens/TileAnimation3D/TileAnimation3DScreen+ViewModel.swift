import Foundation
import Observation

// MARK: - TileAnimation3DScreen+ViewModel

extension TileAnimation3DScreen {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var row: Int
        private(set) var column: Int
        private(set) var rotations: [[Int]]
        private(set) var positions: [IndexPath]

        init(row: Int, column: Int) {
            self.row = row
            self.column = column
            let rotations = (0..<row).map { _ in
                (0..<column).map { _ in Int.random(in: 0..<4) }
            }
            self.rotations = rotations

            var position: IndexPath {
                [(0..<row).randomElement()!, (0..<column).randomElement()!]
            }
            self.positions = [position, position, position]
        }
    }
}

extension TileAnimation3DScreen.ViewModel {
    func rotate() {
        for i in 0..<positions.count {
            var movements = [IndexPath]()
            let current = positions[i]
            if current[0] > 0 {
                movements += [[-1, 0]]
            }
            if current[1] > 0 {
                movements += [[0, -1]]
            }
            if current[0] < rotations.count - 1 {
                movements += [[+1, 0]]
            }
            if current[1] < rotations[0].count - 1 {
                movements += [[0, +1]]
            }
            let movement = movements.randomElement()!
            positions[i][0] += movement[0]
            positions[i][1] += movement[1]

            let index = positions[i]
            rotations[index[0]][index[1]] += 1
        }
    }
}
