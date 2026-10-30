import MyToyboxCore
import SwiftUI

// MARK: - TileAnimationScreen

@Metadata(title: .screenTileAnimationTitle, description: .screenTileAnimationDescription, tags: [.animation])
public struct TileAnimationScreen: View {
    public init() {}

    @State private var viewModel: ViewModel?
    @State private var lineWidth: Double = 16
    /// The latest measured size, which drives the debounced grid setup.
    @State private var size = CGSize.zero

    public var body: some View {
        Group {
            if let viewModel {
                ContentView(viewModel: viewModel, lineWidth: lineWidth)
                    .id([viewModel.row, viewModel.column])
            } else {
                Color.clear
            }
        }
        // Measure the full available area rather than the aspect-fit grid.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundExtensionEffect()
        .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
            self.size = size
        }
        .task(id: size) {
            await setup(with: size)
        }
    }

    /// Recomputes the grid dimensions for the given size.
    ///
    /// The view model is rebuilt only when the row or column count changes,
    /// so the animation state survives live resizes that keep the same grid.
    /// The first setup runs immediately; later ones are debounced so dragging a
    /// Mac window or a Stage Manager edge does not restart the animation on
    /// every frame. The task is cancelled when the size changes again first.
    private func setup(with size: CGSize) async {
        guard size.width > 0, size.height > 0 else { return }
        if viewModel != nil {
            do {
                try await Task.sleep(for: .milliseconds(150))
            } catch {
                return
            }
        }
        let row: Int
        let column: Int
        if size.height > size.width {
            column = 8
            row = Int(Double(column) * size.height / size.width)
        } else {
            row = 8
            column = Int(Double(row) * size.width / size.height)
        }
        if viewModel?.row != row || viewModel?.column != column {
            viewModel = ViewModel(row: row, column: column)
        }
        // Scale the stroke with the tile size (16pt for a 50pt tile).
        let tileSize = min(size.width / Double(column), size.height / Double(row))
        lineWidth = tileSize * 0.32
    }
}

// MARK: TileAnimationScreen.ContentView

private extension TileAnimationScreen {
    struct ContentView: View {
        var viewModel: ViewModel
        var lineWidth: Double
        @State private var lastUpdateDate = Date.now

        var body: some View {
            TimelineView(.animation) { context in
                let date = context.date
                let interval = date.timeIntervalSince(lastUpdateDate)
                Grid(horizontalSpacing: .zero, verticalSpacing: .zero) {
                    let rotations = viewModel.rotations
                    ForEach(0 ..< rotations.count, id: \.self) { i in
                        GridRow {
                            ForEach(0 ..< rotations[i].count, id: \.self) { j in
                                Tile(radians: Double(rotations[i][j]) * .pi / 2, lineWidth: lineWidth)
                            }
                        }
                    }
                }
                .scaledToFit()
                .foregroundStyle(.blue)
                .backgroundExtensionEffect()
                .animation(.spring(duration: 0.8), value: viewModel.rotations)
                .onChange(of: interval, initial: true) { _, interval in
                    if interval > 1 {
                        lastUpdateDate = date
                        viewModel.rotate()
                    }
                }
            }
        }
    }
}

// MARK: TileAnimationScreen.Tile

extension TileAnimationScreen {
    struct Tile: View {
        let radians: Double
        let lineWidth: Double

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
    TileAnimationScreen()
}
