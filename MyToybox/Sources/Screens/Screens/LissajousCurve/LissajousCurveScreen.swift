import Observation
import SwiftUI

// MARK: - LissajousCurve

/// An observable data model representing the parameters of a Lissajous curve,
/// used to control the animation and appearance of the curve in SwiftUI views.
///
/// - Note: This model is intended to be shared between multiple views and updated interactively.
///
@Observable
final class LissajousCurve {
    /// Frequency multiplier for the x-axis. Determines how many times the curve oscillates horizontally.
    var k: Double = 2

    /// Frequency multiplier for the y-axis. Determines how many times the curve oscillates vertically.
    var l: Double = 3

    /// The current phase offset (in radians) applied to the x component.
    /// This value is animated over time to produce continuous motion.
    var phase: Double = 0.0

    /// The number of sample points used to generate the curve's path.
    /// A higher value results in a smoother curve, but may decrease performance on low-end devices.
    var samples: Int = 5000
}

// MARK: - LissajousCurveDemoScreen

/// The main demo screen that displays an animated Lissajous curve
/// and provides interactive controls for users to adjust its parameters in real time.
struct LissajousCurveDemoScreen: View {
    /// The shared state model holding all parameters for the Lissajous curve.
    @State var model = LissajousCurve()

    var body: some View {
        VStack(spacing: 16) {
            Text("Lissajous Curve")
                .font(.title)
                .bold()
            LissajousCurveAnimationView(model: model)
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 6)
            LissajousCurveControlView(model: model)
        }
        .padding()
    }
}

// MARK: - LissajousCurveAnimationView

/// A view that animates the phase property of the Lissajous curve in real time,
/// creating a smoothly moving visualization.
///
private struct LissajousCurveAnimationView: View {
    /// The data model providing parameters for the curve.
    var model: LissajousCurve

    /// The reference date used as the zero point for the animation timer.
    var referenceDate = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate the elapsed time in seconds since the reference date,
            // mapped to the range [0, 2π).
            let time = context.date
                .timeIntervalSince(referenceDate)
                .truncatingRemainder(dividingBy: 2 * .pi)

            // Update the model's phase, which triggers the curve animation.
            LissajousCurveView(model: model)
                .onChange(of: time, initial: true) { _, time in
                    model.phase = time
                }
        }
    }
}

// MARK: - LissajousCurveView

/// A view that renders the Lissajous curve using SwiftUI's Canvas API.
/// The stroke color is dynamically blended from the parameter values,
/// making the visualization more expressive.
private struct LissajousCurveView: View {
    /// The parameter model providing all values needed to draw the curve.
    var model: LissajousCurve

    var body: some View {
        Canvas { context, size in
            // Build the path for the current parameter values.
            let path = LissajousCurveShape(model: model)
                .path(in: CGRect(origin: .zero, size: size))

            // Stroke the curve path with a blended color.
            context.stroke(path, with: .color(.color(model)), lineWidth: 4)
        }
        .scaledToFit()
    }
}

// MARK: - LissajousCurveShape

/// A SwiftUI Shape that generates a Lissajous curve using mathematical parameters.
///
/// The classic Lissajous curve is defined parametrically as:
///     x = cos(k * t + phase)
///     y = sin(l * t)
private struct LissajousCurveShape: Shape {
    /// Frequency multiplier for the x-axis.
    var k: Double
    /// Frequency multiplier for the y-axis.
    var l: Double
    /// Phase shift (radians) for the x-axis.
    var phase: Double
    /// Number of sample points to use for the curve.
    var samples: Int

    /// Initializes a new LissajousCurveShape from the provided parameter model.
    /// - Parameter model: The LissajousCurve model providing parameters.
    init(model: LissajousCurve) {
        k = model.k
        l = model.l
        phase = model.phase
        samples = model.samples
    }

    /// Generates the path for the Lissajous curve, scaled and centered within the provided rectangle.
    func path(in rect: CGRect) -> Path {
        Path { path in
            // Determine the drawing bounds and center.
            let s = min(rect.width, rect.height)
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = s * 0.4

            // Sample points along t in [0, 2π] and construct the curve.
            for i in 0...samples {
                let t = 2 * .pi * Double(i) / Double(samples)
                // Use rounded-down k and l for integer-based periodicity.
                let x = cos(k.rounded(.down) * t + phase)
                let y = sin(l.rounded(.down) * t)
                let point = CGPoint(
                    x: center.x + CGFloat(x) * radius,
                    y: center.y - CGFloat(y) * radius
                )
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
    }
}

// MARK: - LissajousCurveControlView

/// A control panel for interactively adjusting the Lissajous curve parameters.
///
/// Users can modify the 'k' and 'l' frequency multipliers using sliders,
/// and see the updated curve equation in real time.
private struct LissajousCurveControlView: View {
    /// Bindable reference to the shared curve parameter model.
    @Bindable var model: LissajousCurve

    var body: some View {
        VStack {
            // Display the curve's formula with the current parameters (rounded to integers).
            Text("x = cos(\(Int(model.k))t), y = sin(\(Int(model.l))t)")
                .font(.custom("Times New Roman", size: 28, relativeTo: .title2))
            Grid(horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text("99").hidden()  // Placeholder to align the numbers.
                        Text("\(Int(model.k))")
                    }
                    Slider(value: $model.k.animation(), in: 1...10)
                        .tint(.colorX(model))
                }
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text("99").hidden()
                        Text("\(Int(model.l))")
                    }
                    Slider(value: $model.l.animation(), in: 1...10)
                        .tint(.colorY(model))
                }
            }
        }
        .font(.title2)
        .monospacedDigit()
        .contentTransition(.numericText())
        .frame(maxWidth: .infinity, alignment: .trailing)
        // Animate changes to the slider values smoothly.
        .animation(.default, value: model.k)
        .animation(.default, value: model.l)
    }
}

// MARK: - Color Extensions

extension Color {
    /// Returns a blended color based on the Lissajous curve's parameters,
    /// used as the stroke color for the curve.
    fileprivate static func color(_ curve: LissajousCurve) -> Color {
        colorX(curve).mix(with: colorY(curve), by: 0.5)
    }

    /// Returns a hue-based color for the 'k' parameter.
    /// The color cycles as 'k' is varied.
    fileprivate static func colorX(_ curve: LissajousCurve) -> Color {
        let x = (1.0 + cos(curve.k * (2 * .pi / 20.0))) / 2.0
        return Color(hue: x, saturation: 1, brightness: 1)
    }

    /// Returns a hue-based color for the 'l' parameter.
    /// The color cycles as 'l' is varied.
    fileprivate static func colorY(_ curve: LissajousCurve) -> Color {
        let y = (1.0 + cos(curve.l * (2 * .pi / 20.0))) / 2.0
        return Color(hue: y, saturation: 1, brightness: 1)
    }
}

// MARK: - Preview

#Preview {
    LissajousCurveDemoScreen()
}
