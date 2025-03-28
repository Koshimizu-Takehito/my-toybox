import Observation
import SwiftUI

// MARK: - TileAnimation3DScreen

struct TileAnimation3DScreen: View {
    @State private var model: TileAnimation3DScreenViewModel?
    @State var lineWidth: Double?

    var body: some View {
        Group {
            if let model, let lineWidth {
                TileAnimation3DScreenContent(model: model, lineWidth: lineWidth)
                    .id([model.row, model.column])
            } else {
                Color.clear
            }
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
            let column = 10
            let row = max(Int(ceil(Double(column) * size.height / size.width)), column)
            self.model = TileAnimation3DScreenViewModel(row: row, column: column)
            self.lineWidth = min(size.height, size.width) / Double(min(row, column)) / 5
        }
        .ignoresSafeArea()
    }
}

// MARK: - TileAnimation3DScreenContent

private struct TileAnimation3DScreenContent: View {
    var model: TileAnimation3DScreenViewModel
    var lineWidth: Double
    @State var lastUpdateDate = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let date = context.date
            let interval = date.timeIntervalSince(lastUpdateDate)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                let rotations = model.rotations
                ForEach(0..<rotations.count, id: \.self) { i in
                    GridRow {
                        ForEach(0..<rotations[i].count, id: \.self) { j in
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
            .animation(.linear(duration: 1.3), value: model.rotations)
            .onChange(of: interval, initial: true) { _, interval in
                if interval > 0.1 {
                    lastUpdateDate = date
                    model.rotate()
                }
            }
        }
    }
}

// MARK: - Tile

private struct Tile: View {
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
