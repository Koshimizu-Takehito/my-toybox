import SwiftUI

extension TileAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let rotations: [[Int]] = [[0, 1], [1, 0]]
        Grid(horizontalSpacing: .zero, verticalSpacing: .zero) {
            ForEach(0 ..< rotations.count, id: \.self) { i in
                GridRow {
                    ForEach(0 ..< rotations[i].count, id: \.self) { j in
                        Tile(radians: Double(rotations[i][j]) * .pi / 2, lineWidth: 4)
                    }
                }
            }
        }
    }
}
