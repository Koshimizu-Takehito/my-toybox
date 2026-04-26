import Observation
import SwiftUI

// MARK: - TileAnimation3DScreen

@Metadata(title: .screenTileAnimation3DTitle, description: .screenTileAnimation3DDescription, tags: [.animation])
struct TileAnimation3DScreen: View {
    @State private var viewModel: ViewModel?
    @State private var lineWidth: Double?

    var body: some View {
        Group {
            if let viewModel, let lineWidth {
                TileAnimation3DScreenContent(viewModel: viewModel, lineWidth: lineWidth)
                    .id([viewModel.row, viewModel.column])
            } else {
                Color.clear
            }
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
            let column = 10
            let row = max(Int(ceil(Double(column) * size.height / size.width)), column)
            viewModel = ViewModel(row: row, column: column)
            lineWidth = min(size.height, size.width) / Double(min(row, column)) / 5
        }
        .backgroundExtensionEffect()
    }
}

// MARK: - TileAnimation3DScreenContent

private struct TileAnimation3DScreenContent: View {
    typealias Tile = TileAnimation3DScreen.Tile
    var viewModel: TileAnimation3DScreen.ViewModel
    var lineWidth: Double
    @State private var lastUpdateDate = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let date = context.date
            let interval = date.timeIntervalSince(lastUpdateDate)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                let rotations = viewModel.rotations
                ForEach(0 ..< rotations.count, id: \.self) { i in
                    GridRow {
                        ForEach(0 ..< rotations[i].count, id: \.self) { j in
                            Tile(radians: Double(rotations[i][j]) * .pi / 2, lineWidth: lineWidth)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .scaledToFit()
            .padding(.horizontal, -200)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotation3DEffect(.radians(0.4 * .pi), axis: (1, 0, 0), anchor: .top)
            .animation(.linear(duration: 1.3), value: viewModel.rotations)
            .onChange(of: interval, initial: true) { _, interval in
                if interval > 0.1 {
                    lastUpdateDate = date
                    viewModel.rotate()
                }
            }
        }
    }
}

// MARK: - TileAnimation3DScreen.Tile

extension TileAnimation3DScreen {
    struct Tile: View {
        let radians: Double
        var lineWidth: Double

        var body: some View {
            ZStack {
                QuarterArc()
                    .stroke(lineWidth: lineWidth)
                    .rotationEffect(.radians(radians))
                QuarterArc()
                    .stroke(lineWidth: lineWidth)
                    .rotationEffect(.radians(.pi + radians))
            }
        }
    }
}

// MARK: - QuarterArc

private struct QuarterArc: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(x: rect.maxX, y: rect.minY),
                radius: min(rect.midX, rect.midY),
                startAngle: .degrees(180 + 1),
                endAngle: .degrees(90 - 1),
                clockwise: true
            )
        }
    }
}

#Preview {
    TileAnimation3DScreen()
}
