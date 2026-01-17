import SwiftUI

// MARK: - TileAnimationScreen

@Metadata(title: "Tile Animation", description: "タイルアニメーション", tags: [.animation])
struct TileAnimationScreen: View {
    @State private var viewModel: ViewModel?

    var body: some View {
        if let viewModel {
            ContentView(viewModel: viewModel)
                .ignoresSafeArea()
                .id([viewModel.row, viewModel.column])
        } else {
            Color.clear
                .ignoresSafeArea()
                .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                    setup(with: size)
                }
        }
    }

    private func setup(with size: CGSize) {
        if size == .zero {
            return
        } else if size.height > size.width {
            let column = 8
            let row = Int(Double(column) * size.height / size.width)
            viewModel = ViewModel(row: row, column: column)
        } else {
            let row = 8
            let column = Int(Double(row) * size.width / size.height)
            viewModel = ViewModel(row: row, column: column)
        }
    }
}

// MARK: TileAnimationScreen.ContentView

private extension TileAnimationScreen {
    struct ContentView: View {
        var viewModel: ViewModel
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
                                Tile(radians: Double(rotations[i][j]) * .pi / 2)
                            }
                        }
                    }
                }
                .scaledToFit()
                .foregroundStyle(.blue)
                .ignoresSafeArea()
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

// MARK: - Tile

private struct Tile: View {
    let radians: Double

    var body: some View {
        ZStack {
            QuarterArc()
                .stroke(lineWidth: 16)
                .rotationEffect(.radians(radians))
            QuarterArc()
                .stroke(lineWidth: 16)
                .rotationEffect(.radians(.pi + radians))
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
