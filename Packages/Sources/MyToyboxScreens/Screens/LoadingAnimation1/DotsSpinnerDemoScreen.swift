import SwiftUI

// MARK: - Model

/// Holds the user‑tunable parameters for the dots spinner.
///
/// * `count` – number of dots (also used as the number of distinct colors).
/// * `width` – the desired outer width of the spinner view.
///
/// `@Observable` makes the model publish its properties so that any SwiftUI
/// view observing it automatically redraws when a value changes.
@Observable
final class DotsSpinnerModel {
    /// Fixed palette from which the first `count` colors are picked.
    static let colors: [Color] = [
        .purple, .red, .yellow, .blue, .green, .brown, .cyan, .orange, .pink,
    ]

    /// Active number of dots / colors.
    var count: Int

    /// Outer width of the spinner in points.
    var width: Double

    /// Convenience computed array returning only the first `count` colors.
    var colors: [Color] {
        Array(Self.colors[0..<min(count, Self.colors.count)])
    }

    init(count: Int = 5, width: Double = 340) {
        self.count = count
        self.width = width
    }
}

// MARK: - Demo Screen

/// Complete sample screen that embeds the spinner and its controls.
struct DotsSpinnerDemoScreen: View {
    /// Observable model stored in View State.
    @State private var model = DotsSpinnerModel()

    var body: some View {
        VStack {
            Spacer()
            DotsSpinnerView(model: model)
            Spacer()
            DotsSpinnerControl(model: model)
        }
    }
}

// MARK: - Control Panel

/// UI that lets the user tweak the spinner parameters in real time.
struct DotsSpinnerControl: View {
    /// Using the new `@Bindable` macro introduced in Swift 5.9 so any change
    /// made by the sliders immediately updates the model.
    @Bindable var model: DotsSpinnerModel

    var body: some View {
        VStack {
            // Width control
            HStack {
                Text("Width")
                Slider(value: $model.width.animation(), in: 50...340)
            }
            Divider()

            // Colors / dot count control
            Stepper(value: $model.count, in: 1...DotsSpinnerModel.colors.count) {
                Text("Colors")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .padding()
    }
}

// MARK: - Spinner View

/// Renders an animated pair of counter‑rotating dot rings.
///
/// The animation relies on `TimelineView(.animation)` which guarantees a frame
/// callback on every SwiftUI animation tick (≈ 60 fps). Each ring is offset by
/// half a segment so that dots intersect on opposite sides, creating an
/// eye‑catching "yin‑yang" motion.
struct DotsSpinnerView: View {
    var model: DotsSpinnerModel

    var body: some View {
        let colors = model.colors
        GeometryReader { geometry in
            let side = geometry.size.width

            TimelineView(.animation) { context in
                ZStack {
                    let count = colors.count
                    let dotSize = (30.0 / 340.0) * side  // keeps dot size proportional
                    let radius = 2 * dotSize
                    ForEach(0..<count, id: \.self) { index in
                        // Base angle that advances over time.
                        let theta = 3 * context.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: 2 * .pi)
                        // Angular offset for the two rings
                        let offset = Double(index) * (2 * .pi) / Double(count)
                        let halfStep = (count % 2 == 0) ? .pi / Double(count) : .zero
                        // Clockwise ring
                        DotView(
                            radius: radius,
                            theta: theta,
                            offset: offset,
                            color: colors[index],
                            reverse: false
                        )
                        // Counter‑clockwise ring
                        DotView(
                            radius: radius,
                            theta: theta,
                            offset: offset + halfStep,
                            color: colors[index],
                            reverse: true
                        )
                    }
                    .frame(width: dotSize)
                }
            }
            .padding()
            .frame(width: side, height: side)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 0.25 * side))
        }
        .scaledToFit()
        .frame(width: model.width)
    }
}

// MARK: - Dot Sub‑view

/// Single dot that follows a circular trajectory with optional direction reversal.
///
/// The scale changes over the cycle to add depth, and a drop shadow sells a
/// subtle 3‑D feel.
private struct DotView: View {
    /// Orbit radius
    var radius: Double
    /// Current phase (radians)
    var theta: Double
    /// Per‑dot angular offset
    var offset: Double
    /// Color of dot
    var color: Color
    /// Counter‑rotate flag
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
