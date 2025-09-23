import SwiftUI

// MARK: - MultiHelixScreen

struct MultiHelixScreen: View {
    @State var numberOfMarbles = 6
    @State var numberOfColors = 2
    @State var gradients: [Gradient] = [
        [Color(red: 0.98, green: 0.57, blue: 0.16), Color(red: 0.95, green: 0.15, blue: 0.01)],
        [Color(red: 0.23, green: 0.77, blue: 1.00), Color(red: 0.02, green: 0.32, blue: 0.73)],
        [Color(red: 0.04, green: 1.00, blue: 0.52), Color(red: 0.10, green: 0.52, blue: 0.31)],
        [Color(red: 0.98, green: 0.00, blue: 0.74), Color(red: 0.51, green: 0.03, blue: 0.46)],
        [Color(red: 0.97, green: 1.00, blue: 0.02), Color(red: 0.46, green: 0.47, blue: 0.07)],
        [Color(red: 1.00, green: 0.21, blue: 0.22), Color(red: 0.52, green: 0.01, blue: 0.16)],
    ]
    .map(Gradient.init)

    var body: some View {
        VStack {
            MultiHelixAnimationView(
                count: numberOfMarbles,
                gradients: Array(gradients[0..<numberOfColors])
            )
            .border(.cyan)

            Stepper("marbles: \(numberOfMarbles)", value: $numberOfMarbles, in: 1...20)
            Stepper("colors: \(numberOfColors)", value: $numberOfColors, in: 1...gradients.count)
        }
        .padding()
    }
}

// MARK: - MultiHelixAnimationView

struct MultiHelixAnimationView<S: Shape>: View {
    var shape: S
    var count: Int = 10
    var gradients: [Gradient]

    init(_ shape: S = Circle(), count: Int, gradients: [Gradient]) {
        self.shape = shape
        self.count = count
        self.gradients = gradients
    }

    var body: some View {
        TimelineView(.animation) { context in
            let phase = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 2.0 * .pi)
            Canvas { context, size in
                for item in items(in: size, phase: phase) {
                    context.fill(item.path, with: item.shading)
                }
            }
        }
        .aspectRatio(3.0/2.0, contentMode: .fit)
    }

    private func items(in canvas: CGSize, phase: Double) -> [Item<S>] {
        gradients.enumerated().lazy.map { offset, gradient in
            let phase = phase + (2.0 * .pi) * (Double(offset) / Double(gradients.count))
            return itemRects(in: canvas, phase: phase).map { rect in
                Item(shape: shape, rect: rect, gradient: gradient)
            }
        }
        .flatMap(\.self)
        .sorted(by: <)
    }

    private func itemRects(in canvas: CGSize, phase: Double) -> [CGRect] {
        let count = CGFloat(count)
        let x = canvas.width / count
        let y = canvas.height / count
        let r = min(x, y)
        return stride(from: 0.0, to: count, by: 1.0).map { i in
            var scale = 0.5 * (cos(phase + 2.0 * .pi * (i / count)) + 1.0)
            scale = 0.5 * (scale + 1)
            let offset = 0.5 * (sin(phase + 2.0 * .pi * (i / count)) + 1.0)
            var item = CGRect(origin: .zero, size: CGSize(width: r, height: r))
            item.size.width *= scale
            item.size.height *= scale
            item.origin.x = x * (i + 0.5 * (1.0 - scale)) + item.size.width / 4.0
            item.origin.y = y * ((count - 1) * offset + 0.5 * (1.0 - scale))
            return item
        }
    }
}

// MARK: - Item

private struct Item<S: Shape> {
    var shape: S
    var rect: CGRect
    var gradient: Gradient

    var shading: GraphicsContext.Shading {
        GraphicsContext.Shading.linearGradient(
            gradient,
            startPoint: .init(x: .zero, y: rect.origin.y),
            endPoint: .init(x: .zero, y: rect.origin.y + rect.size.height)
        )
    }

    nonisolated var path: Path {
        shape.path(in: rect)
    }

    nonisolated static func < (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.rect.width * lhs.rect.height < rhs.rect.width * rhs.rect.height
    }
}

// MARK: - Preview

#Preview {
    MultiHelixScreen()
}
