import Observation
import SwiftUI

// MARK: - LissajousCurve1

/// Encapsulates all parameters necessary to define and animate a Lissajous curve.
///
/// The Lissajous curve is mathematically represented as:
///     x = cos(k * t + phase)
///     y = sin(l * t)
/// where `k` and `l` determine the frequency of oscillation in x and y, and `phase` animates the curve.
nonisolated struct LissajousCurve1 {
    /// Frequency multiplier for the x-axis (number of horizontal lobes).
    var k: Double = 2

    /// Frequency multiplier for the y-axis (number of vertical lobes).
    var l: Double = 3

    /// Phase offset in radians applied to the x component. This is animated in real time.
    var phase: Double = 0.0

    /// Number of sample points along the curve. Higher values yield smoother curves.
    var samples: Int = 5000

    /// Computes a point on the Lissajous curve for the given sample index.
    /// - Parameters:
    ///   - index: The sample point index along the curve (0...samples).
    ///   - center: The center point of the drawing area.
    ///   - radius: The curve's maximum radius from the center.
    /// - Returns: The computed CGPoint on the curve.
    func point(at index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let t = 2 * .pi * Double(index) / Double(samples)
        // Use rounded-down k and l for integer-based periodicity.
        let xValue = cos(k.rounded(.down) * t + phase)
        let yValue = sin(l.rounded(.down) * t)
        return CGPoint(x: radius * xValue + center.x, y: radius * yValue + center.y)
    }
}

// MARK: - LissajousCurveDemoScreen1

/// The main screen displaying the animated Lissajous curve with interactive controls.
/// Users can adjust parameters and observe their effects in real time.
@Metadata(title: .screenLissajousCurveInteractiveTitle, description: .screenLissajousCurveInteractiveDescription, tags: [.animation])
struct LissajousCurveDemoScreen1: View {
    /// State model holding all curve parameters.
    @State private var curve = LissajousCurve1()

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Lissajous Curve")
                .font(.title)
                .bold()
            LissajousCurveAnimationView1(curve: $curve)
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 6)
            LissajousCurveControlView(curve: $curve)
        }
        .padding()
    }
}

// MARK: - LissajousCurveAnimationView1

/// A view that animates the phase parameter of the Lissajous curve,
/// resulting in continuous motion.
struct LissajousCurveAnimationView1: View {
    /// Binding to the shared curve parameter model.
    @Binding var curve: LissajousCurve1

    var lineWidth: CGFloat = 4.0

    /// Reference date used as the starting point for the animation timer.
    private let animationStartDate = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate elapsed time since animation started, mapped to [0, 2π).
            let time = context.date
                .timeIntervalSince(animationStartDate)
                .truncatingRemainder(dividingBy: 2 * .pi)

            // Update the phase parameter, animating the curve.
            LissajousCurveView1(curve: curve, lineWidth: lineWidth)
                .onChange(of: time, initial: true) { _, newTime in
                    curve.phase = newTime
                }
        }
    }
}

// MARK: - LissajousCurveView1

/// Renders the Lissajous curve using SwiftUI's Canvas API.
/// The stroke color is dynamically computed based on the current parameters.
struct LissajousCurveView1: View {
    /// The parameter model providing all values needed to draw the curve.
    var curve: LissajousCurve1
    var lineWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            // Build the path for the current parameter values.
            let path = LissajousCurveShape(curve: curve)
                .path(in: CGRect(origin: .zero, size: size))

            // Stroke the curve path with a dynamically blended color.
            context.stroke(path, with: .color(.color(curve)), lineWidth: lineWidth)
        }
        .scaledToFit()
    }
}

// MARK: - LissajousCurveShape

/// A Shape that generates a Lissajous curve path using the supplied parameters.
/// The curve is sampled at a specified number of points and centered in the provided rectangle.
private struct LissajousCurveShape: Shape {
    /// The parameter model, which provides frequency multipliers, phase, and sample count.
    var curve: LissajousCurve1

    /// Generates the path for the Lissajous curve, scaled and centered within the provided rectangle.
    /// - Parameter rect: Drawing bounds for the curve.
    /// - Returns: The path representing the Lissajous curve.
    func path(in rect: CGRect) -> Path {
        Path { path in
            let sideLength = min(rect.width, rect.height)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = sideLength * 0.4

            // Sample points along t in [0, 2π] and construct the curve.
            path.move(to: curve.point(at: 0, center: center, radius: radius))
            for i in 1 ... curve.samples {
                path.addLine(to: curve.point(at: i, center: center, radius: radius))
            }
        }
    }
}

// MARK: - LissajousCurveControlView

/// UI panel for interactively adjusting the Lissajous curve's k and l parameters.
/// Provides sliders and a real-time preview of the curve's mathematical equation.
private struct LissajousCurveControlView: View {
    /// Binding to the shared curve parameter model.
    @Binding var curve: LissajousCurve1

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                // Show current equation and phase (as multiples of π, rounded for clarity).
                let phaseString = (curve.phase / .pi).formatted(.number.precision(.fractionLength(3)))
                HStack(spacing: 0) {
                    Text(verbatim: "x = cos(\(Int(curve.k))t")
                    Text(verbatim: " + \(phaseString)π)")
                }
                .flipsForRightToLeftLayoutDirection(false)
                Text(verbatim: "y = sin(\(Int(curve.l))t)")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .fontDesign(.monospaced)

            Grid(horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "99").hidden() // Alignment placeholder.
                        Text(verbatim: "\(Int(curve.k))")
                    }
                    Slider(value: $curve.k.animation(), in: 1 ... 10)
                        .tint(.colorX(curve))
                }
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "99").hidden()
                        Text(verbatim: "\(Int(curve.l))")
                    }
                    Slider(value: $curve.l.animation(), in: 1 ... 10)
                        .tint(.colorY(curve))
                }
            }
        }
        .font(.title2)
        .monospacedDigit()
        .contentTransition(.numericText())
        .frame(maxWidth: .infinity, alignment: .trailing)
        .animation(.default, value: curve.k)
        .animation(.default, value: curve.l)
    }
}

// MARK: - Color Extensions

private extension Color {
    /// Returns a blended color based on the Lissajous curve's k and l parameters,
    /// for use as the stroke color of the curve.
    static func color(_ curve: LissajousCurve1) -> Color {
        colorX(curve).mix(with: colorY(curve), by: 0.5)
    }

    /// Generates a color based on the k parameter.
    static func colorX(_ curve: LissajousCurve1) -> Color {
        let x = (1.0 + sin(curve.k * (2 * .pi / 20.0))) / 2.0
        return Color(hue: x, saturation: 1, brightness: 1)
    }

    /// Generates a color based on the l parameter.
    static func colorY(_ curve: LissajousCurve1) -> Color {
        let y = (1.0 + sin(curve.l * (2 * .pi / 20.0))) / 2.0
        return Color(hue: y, saturation: 1, brightness: 1)
    }
}

// MARK: - Preview

#Preview {
    LissajousCurveDemoScreen1()
}
