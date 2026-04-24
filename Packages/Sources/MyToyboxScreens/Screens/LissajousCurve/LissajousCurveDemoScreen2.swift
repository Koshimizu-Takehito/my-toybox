import Observation
import SwiftUI

// MARK: - LissajousCurveDemoScreen2

/**
 The main demo screen that displays an interactive, animated Lissajous curve.

 - This screen is intended for educational and experimental purposes.
 - Users can visually explore how changing the Lissajous curve's parameters (k, l, phase) affects its shape.
 - Animation and UI controls are provided for a real-time experience.
 */
@Metadata(title: .screenLissajousCurveVariantTitle, description: .screenLissajousCurveVariantDescription, tags: [.animation])
struct LissajousCurveDemoScreen2: View {
    /// State model that holds all the current curve parameters.
    @State private var curve = LissajousCurve2()

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Lissajous Curve")
                .font(.title)
                .bold()
            // The animated curve visualization
            LissajousCurveAnimationView2(curve: $curve)
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 6)
            // Parameter controls
            LissajousCurveControlView(curve: $curve)
        }
        .padding()
    }
}

// MARK: - LissajousCurveAnimationView2

/**
 Animates the phase parameter of the Lissajous curve for a smooth, continuous motion.

 - Uses TimelineView for a frame-synced timer.
 - The phase parameter is updated in real time, making the curve "move".
 - Intended for embedding inside a larger UI or educational demo.
 */
struct LissajousCurveAnimationView2: View {
    /// Shared binding to the curve parameter model.
    @Binding var curve: LissajousCurve2
    var lineWidth: CGFloat = 4.0

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate elapsed time since animation start, mapped to [0, 2π).
            let time = context.date
                .timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 2 * .pi)

            // Update the phase, which animates the curve.
            LissajousCurveView2(curve: curve, lineWidth: lineWidth)
                .onChange(of: time, initial: true) { _, newTime in
                    curve.phase = newTime
                }
        }
    }
}

// MARK: - LissajousCurveView2

/**
 Renders the Lissajous curve using SwiftUI's Canvas API.

 - The curve's color is dynamically blended based on its parameters.
 - Supports animation via the Animatable protocol.
 - Use this view wherever you need a visual representation of a Lissajous curve.
 */
struct LissajousCurveView2: View, @MainActor Animatable {
    /// Parameter model containing all values needed to draw the curve.
    var curve: LissajousCurve2
    var lineWidth: CGFloat

    nonisolated var animatableData: LissajousCurve2 {
        get { curve }
        set { curve = newValue }
    }

    var body: some View {
        Canvas { context, size in
            // Create the path for the current parameters.
            let path = LissajousCurveShape(curve: curve)
                .path(in: CGRect(origin: .zero, size: size))

            // Draw the path with a dynamically blended color.
            context.stroke(path, with: .color(.color(curve)), lineWidth: lineWidth)
        }
        .scaledToFit()
    }
}

// MARK: - LissajousCurveShape

/**
 A SwiftUI Shape that generates a Lissajous curve based on the provided parameters.

 - The curve is sampled at a high number of points for smoothness.
 - The shape is centered and scaled to fit the drawing rect.
 - Used internally for custom drawing.
 */
private struct LissajousCurveShape: Shape {
    /// The parameter model (k, l, phase, samples).
    var curve: LissajousCurve2

    var animatableData: LissajousCurve2 {
        get { curve }
        set { curve = newValue }
    }

    /**
     Generates the path for the Lissajous curve, scaled and centered.

     - Parameter rect: Drawing bounds.
     - Returns: A SwiftUI Path describing the curve.
     */
    func path(in rect: CGRect) -> Path {
        Path { path in
            let sideLength = min(rect.width, rect.height)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = sideLength * 0.4

            // Start at t = 0, then add lines through sampled points.
            path.move(to: curve.point2(at: 0, center: center, radius: radius))
            for i in 1 ... curve.samples {
                path.addLine(to: curve.point2(at: i, center: center, radius: radius))
            }
        }
    }
}

// MARK: - LissajousCurveControlView

/**
 A UI panel for interactively adjusting the Lissajous curve's parameters.

 - Provides controls for k and l values (frequency multipliers).
 - Displays the mathematical equations with the current parameter values.
 - Uses Sliders for easy experimentation and real-time feedback.
 - All changes are reflected immediately in the curve visualization.
 */
private struct LissajousCurveControlView: View {
    /// Binding to the curve parameter model.
    @Binding var curve: LissajousCurve2

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                // Display the current equation, including phase as a multiple of π.
                let phaseString = (curve.phase / .pi).formatted(
                    .number.precision(.fractionLength(3))
                )
                HStack(spacing: 0) {
                    Text(verbatim: "x = cos(\(Int(curve.k))t")
                    Text(verbatim: " + \(phaseString)π)")
                }
                .flipsForRightToLeftLayoutDirection(false)
                Text(verbatim: "y = sin(\(Int(curve.l))t)")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .fontDesign(.monospaced)

            // Parameter adjustment controls for k and l.
            Grid(horizontalSpacing: 8, verticalSpacing: 4) {
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "99").hidden() // Placeholder for alignment.
                        Text(verbatim: "\(Int(curve.k))")
                    }
                    Slider(value: $curve.k.animation(), in: 1 ... 10) { value in
                        if !value { // On drag end, snap to nearest integer.
                            withAnimation(.snappy) {
                                curve.k = curve.k.rounded(.toNearestOrEven)
                            }
                        }
                    }
                    .tint(.colorX(curve))
                }
                GridRow {
                    ZStack(alignment: .trailing) {
                        Text(verbatim: "99").hidden()
                        Text(verbatim: "\(Int(curve.l))")
                    }
                    Slider(value: $curve.l.animation(), in: 1 ... 10) { value in
                        if !value {
                            withAnimation(.snappy) {
                                curve.l = curve.l.rounded(.toNearestOrEven)
                            }
                        }
                    }
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
    /**
     Returns a color blended from the k and l parameter colors, for use as the curve's stroke.

     - Parameter curve: The LissajousCurve instance.
     - Returns: A visually dynamic Color.
     */
    static func color(_ curve: LissajousCurve2) -> Color {
        colorX(curve).mix(with: colorY(curve), by: 0.5)
    }

    /**
     Generates a color based on the k parameter (frequency in x).

     - Returns: A hue varying smoothly with k.
     */
    static func colorX(_ curve: LissajousCurve2) -> Color {
        let x = (1.0 + sin(curve.k * (2 * .pi / 20.0))) / 2.0
        return Color(hue: x, saturation: 1, brightness: 1)
    }

    /**
     Generates a color based on the l parameter (frequency in y).

     - Returns: A hue varying smoothly with l.
     */
    static func colorY(_ curve: LissajousCurve2) -> Color {
        let y = (1.0 + sin(curve.l * (2 * .pi / 20.0))) / 2.0
        return Color(hue: y, saturation: 1, brightness: 1)
    }
}

// MARK: - LissajousCurve2

/**
 A struct that encapsulates all parameters for a Lissajous curve, supporting animation and smooth parameter interpolation.

 - Lissajous curves are defined by the parametric equations:
    x = cos(k * t + phase)
    y = sin(l * t)
   where k, l are frequency multipliers, and phase is an offset.
 - Conforms to VectorArithmetic for seamless animation with SwiftUI.
 - Provides both discrete (integer) and smooth (floating-point) sampling for visual smoothness and periodicity.
 */
nonisolated struct LissajousCurve2: Hashable, VectorArithmetic {
    /// Frequency multiplier for the x-axis (number of horizontal lobes).
    var k: Double = 2

    /// Frequency multiplier for the y-axis (number of vertical lobes).
    var l: Double = 3

    /// Phase offset in radians, animates the curve in real time.
    var phase: Double = 0.0

    /// Number of points to sample for smooth curve rendering.
    var samples: Int = 2000

    /**
     Computes a single point on the Lissajous curve for a given sample index, using integer k and l.

     - Parameters:
        - index: Index along the curve (0...samples).
        - center: The center point of the drawing area.
        - radius: The maximum radius from the center.
     - Returns: The computed CGPoint on the curve.
     */
    func point(at index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let t = 2 * .pi * Double(index) / Double(samples)
        // Use integer k and l for periodic curves.
        let xValue = cos(k.rounded(.toNearestOrEven) * t + phase)
        let yValue = sin(l.rounded(.toNearestOrEven) * t)
        return CGPoint(x: radius * xValue + center.x, y: radius * yValue + center.y)
    }

    /**
     Computes a point with interpolated k and l, for non-integer parameter animation.

     - Parameters:
        - index: The sample index.
        - center: The center of the drawing area.
        - radius: The curve's maximum radius.
     - Returns: An interpolated CGPoint for smooth animation.
     */
    func point2(at index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let point1: CGPoint = {
            var curve1 = self
            curve1.k.round(.down)
            curve1.l.round(.down)
            return curve1.point(at: index, center: center, radius: radius)
        }()
        let point2: CGPoint = {
            var curve2 = self
            curve2.k.round(.up)
            curve2.l.round(.up)
            return curve2.point(at: index, center: center, radius: radius)
        }()
        let k = k.truncatingRemainder(dividingBy: 1)
        let l = l.truncatingRemainder(dividingBy: 1)
        return CGPoint(
            x: (1 - k) * point1.x + k * point2.x,
            y: (1 - l) * point1.y + l * point2.y
        )
    }

    // MARK: VectorArithmetic

    mutating func scale(by rhs: Double) {
        var copy = self
        copy.k *= rhs
        copy.l *= rhs
        copy.phase *= rhs
        self = copy
    }

    var magnitudeSquared: Double {
        k * k + l * l + phase * phase
    }

    static var zero: Self {
        Self(k: 0, l: 0, phase: 0)
    }

    // MARK: AdditiveArithmetic

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(
            k: lhs.k + rhs.k,
            l: lhs.l + rhs.l,
            phase: lhs.phase + rhs.phase,
            samples: (lhs.samples + rhs.samples) / 2
        )
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(
            k: lhs.k - rhs.k,
            l: lhs.l - rhs.l,
            phase: lhs.phase - rhs.phase,
            samples: (lhs.samples + rhs.samples) / 2
        )
    }
}

// MARK: - Preview

#Preview {
    LissajousCurveDemoScreen2()
}
