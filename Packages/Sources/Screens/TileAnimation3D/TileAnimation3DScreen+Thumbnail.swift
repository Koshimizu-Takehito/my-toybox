import MyToyboxCore
import SwiftUI

public extension TileAnimation3DScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let rotations: [[Int]] = [
            [0, 1, 0, 1, 0],
            [1, 0, 1, 0, 1],
            [0, 1, 0, 1, 0],
            [1, 0, 1, 0, 1],
            [0, 1, 0, 1, 0],
        ]
        GeometryReader { _ in
            Grid(horizontalSpacing: .zero, verticalSpacing: .zero) {
                ForEach(0 ..< rotations.count, id: \.self) { i in
                    GridRow {
                        ForEach(0 ..< rotations[i].count, id: \.self) { j in
                            Tile(radians: Double(rotations[i][j]) * .pi / 2, lineWidth: 2)
                        }
                    }
                }
            }
            .rotation3DEffect(.radians(0.4 * .pi), axis: (1, 0, 0), anchor: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    TileAnimation3DScreen.thumbnail
}
