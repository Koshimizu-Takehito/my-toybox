import SwiftUI

// MARK: - View
struct ViewIdentityAnimationScreen: View {
    @State private var model = ViewIdentityAnimationScreenModel(row: 4, column: 4)

    var body: some View {
        VStack(spacing: 20) {
            Group {
                Grid1(angles: model.angles)
                    .overlay { text(title: "Grid1") }
                Grid2(angles: model.angles)
                    .overlay { text(title: "Grid2") }
            }
            .border(.red, width: 6)
            .scaledToFit()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .background(.black, in: .rect)
        .ignoresSafeArea()
        .animation(.spring(duration: 0.8), value: model.angles)
        .task {
            await model.rotate()
        }
    }

    @ViewBuilder
    func text(title: String) -> some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .padding()
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

private struct Grid1: View {
    var angles: [[Angle]]
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(angles, id: \.self) { angles in
                GridRow {
                    ForEach(angles, id: \.self) { angle in
                        Tile(angle: angle)
                    }
                }
            }
        }
    }
}

private struct Grid2: View {
    var angles: [[Angle]]
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<angles.count, id: \.self) { i in
                GridRow {
                    ForEach(0..<angles[i].count, id: \.self) { j in
                        Tile(angle: angles[i][j])
                    }
                }
            }
        }
    }
}

private struct Tile: View {
    let angle: Angle

    var body: some View {
        ZStack {
            QuarterArc()
                .stroke(lineWidth: 16)
                .rotationEffect(angle)
            QuarterArc()
                .stroke(lineWidth: 16)
                .rotationEffect(angle + .radians(.pi))
        }
    }
}

private struct QuarterArc: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(x: rect.maxX, y: rect.minY),
                radius: min(rect.midX, rect.midY),
                startAngle: .degrees(180),
                endAngle: .degrees(90),
                clockwise: true
            )
        }
    }
}

// MARK: - ViewIdentityAnimationScreenViewModel

@MainActor
@Observable
private final class ViewIdentityAnimationScreenModel {
    var angles: [[Angle]]

    init(row: Int, column: Int) {
        angles = (0..<row).map { _ in
            (0..<column).map { _ in
                Angle(radians: Double(Int.random(in: 0..<4)) * .pi/2)
            }
        }
    }

    func rotate() async {
        angles.lazy
            .enumerated()
            .flatMap { xx in
                xx.element.lazy.enumerated().map { x in
                    (i: xx.offset, j: x.offset)
                }
            }
            .shuffled()
            .prefix(2 * angles.count)
            .forEach { i, j in
                angles[i][j] += Angle(radians: Double(i.isMultiple(of: 2) ? 1 : -1) * .pi/2)
            }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await rotate()
    }
}

// MARK: - Preview

#Preview {
    ViewIdentityAnimationScreen()
}
