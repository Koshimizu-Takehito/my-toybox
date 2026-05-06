import MyToyboxCore
import SwiftUI

// MARK: - DotsSpinnerModel

@Observable
final class DotsSpinnerModel {
    static let colors: [Color] = [
        .purple, .red, .yellow, .blue, .green, .brown, .cyan, .orange, .pink,
    ]

    var count: Int
    var width: Double

    var colors: [Color] {
        Array(Self.colors[0 ..< min(count, Self.colors.count)])
    }

    init(count: Int = 5, width: Double = 340) {
        self.count = count
        self.width = width
    }
}

// MARK: - DotsSpinnerDemoScreen

@Metadata(title: .screenLoadingDotsSpinnerTitle, description: .screenLoadingDotsSpinnerDescription, tags: [.animation])
public struct DotsSpinnerDemoScreen: View {
    @State private var model = DotsSpinnerModel()

    public init() {}

    public var body: some View {
        VStack {
            Spacer()
            DotsSpinnerView(model: model)
            Spacer()
            DotsSpinnerControl(model: model)
        }
    }
}

// MARK: - DotsSpinnerControl

struct DotsSpinnerControl: View {
    @Bindable var model: DotsSpinnerModel

    var body: some View {
        VStack {
            HStack {
                Text(verbatim: "Width")
                Slider(value: $model.width.animation(), in: 50 ... 340)
            }
            Divider()
            Stepper(value: $model.count, in: 1 ... DotsSpinnerModel.colors.count) {
                Text(verbatim: "Colors")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .padding()
    }
}

// MARK: - DotsSpinnerView

struct DotsSpinnerView: View {
    var model: DotsSpinnerModel

    var body: some View {
        let colors = model.colors
        GeometryReader { geometry in
            let side = geometry.size.width
            TimelineView(.animation) { context in
                let phase = 3 * context.date
                    .timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 2 * .pi)
                DotsSpinnerContentView(colors: colors, phase: phase, side: side)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 0.25 * side))
            }
        }
        .scaledToFit()
        .frame(width: model.width)
    }
}

// MARK: - DotsSpinnerContentView

struct DotsSpinnerContentView: View {
    var colors: [Color]
    var phase: Double
    var side: CGFloat

    var body: some View {
        ZStack {
            let count = colors.count
            let dotSize = (30.0 / 340.0) * side
            let radius = 2 * dotSize
            ForEach(0 ..< count, id: \.self) { index in
                let offset = Double(index) * (2 * .pi) / Double(count)
                let halfStep = (count % 2 == 0) ? .pi / Double(count) : .zero
                DotView(radius: radius, theta: phase, offset: offset, color: colors[index], reverse: false)
                DotView(radius: radius, theta: phase, offset: offset + halfStep, color: colors[index], reverse: true)
            }
            .frame(width: dotSize)
        }
        .padding(0.05 * side)
        .frame(width: side, height: side)
    }
}

// MARK: - DotView

private struct DotView: View {
    var radius: Double
    var theta: Double
    var offset: Double
    var color: Color
    var reverse = false

    var body: some View {
        let phase = reverse ? -(theta + .pi) : theta
        let scale = 0.5 + abs((phase - .pi).remainder(dividingBy: 2 * .pi)) / (2 * .pi)

        Circle()
            .scaleEffect(x: scale, y: scale)
            .offset(
                x: radius * (cos(phase + offset) + cos(offset)),
                y: radius * (sin(phase + offset) + sin(offset))
            )
            .foregroundStyle(color)
            .rotationEffect(reverse ? .radians(.pi) : .zero)
            .shadow(color: color.opacity(0.3), radius: 10, y: 30 * scale)
    }
}

// MARK: - Preview

#Preview {
    DotsSpinnerDemoScreen()
}
