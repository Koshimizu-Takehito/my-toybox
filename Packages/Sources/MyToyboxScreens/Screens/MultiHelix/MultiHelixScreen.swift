import SwiftUI

// MARK: - MultiHelixScreen

/// A small control panel that previews a multi-helix style animation.
///
/// The screen lets you:
/// - choose how many marbles to render per lane (`marbleCount`)
/// - choose how many color lanes to use from the preset gradient palette (`laneCount`)
///
/// The preview is powered by ``MultiHelixAnimationView``, which renders
/// an animated field of equally spaced marbles that vertically oscillate
/// with a phase offset per color lane.
@Metadata(title: .screenMultiHelixTitle, description: .screenMultiHelixDescription, tags: [.animation])
struct MultiHelixScreen: View {
    /// Total number of marbles to render across the canvas.
    /// This effectively sets the horizontal density (the grid resolution).
    @State private var marbleCount = 6

    /// How many color lanes (gradients) to take from the predefined palette.
    /// The first `laneCount` entries in ``gradientLanes`` are used.
    @State private var laneCount = 2

    /// A preset palette of vertical linear gradients. Each entry represents
    /// one “lane.” Lanes are animated with a per-lane phase offset so
    /// that their oscillations are visually staggered.
    ///
    /// - Tip: Order matters when you vary `laneCount`, because we take
    /// the leading slice `gradientLanes[0..<laneCount]`.
    private let gradientLanes: [Gradient] = [
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
            // The animated preview. Only the first `laneCount` lanes are used.
            MultiHelixAnimationView(
                marbleCount: marbleCount,
                lanes: Array(gradientLanes[0 ..< laneCount])
            )
            .border(.cyan)

            Stepper(value: $marbleCount, in: 1 ... 20) {
                Text(verbatim: "marbles: \(marbleCount)")
            }
            // Changing this clamps how many lanes (gradients) are active.
            Stepper(value: $laneCount, in: 1 ... gradientLanes.count) {
                Text(verbatim: "lanes: \(laneCount)")
            }
        }
        .padding()
    }
}

// MARK: - MultiHelixAnimationView

/// Renders a multi-lane, phase-shifted animation of “marbles” (by default: circles)
/// using `TimelineView(.animation)` + `Canvas`.
///
/// - Each lane corresponds to one vertical gradient in `lanes`.
/// - Each lane’s phase is offset by `2π * (laneIndex / laneCount)`.
/// - The canvas is implicitly divided into a `marbleCount × marbleCount` grid:
///   marbles occupy columns; both the horizontal and vertical step derive from `marbleCount`.
struct MultiHelixAnimationView<S: Shape>: View {
    /// The base shape used for each marble (e.g. `Circle()` by default).
    var shape: S

    /// Number of marbles across the canvas. Also influences vertical spacing,
    /// since both axes derive their step from this count.
    var marbleCount: Int = 10

    /// A list of vertical gradients—one per animated lane. Each lane receives
    /// a distinct phase offset so the motion is visually “multi-helix.”
    var lanes: [Gradient]

    /// Creates a multi-helix animation view.
    ///
    /// - Parameters:
    ///   - shape: The per-item shape to draw (defaults to `Circle()`).
    ///   - marbleCount: How many marbles to place across the canvas.
    ///   - lanes: Lane palette; one lane per gradient.
    init(_ shape: S = Circle(), marbleCount: Int, lanes: [Gradient]) {
        self.shape = shape
        self.marbleCount = marbleCount
        self.lanes = lanes
    }

    var body: some View {
        // Drive animation by the system’s animation timeline. This refreshes
        // in sync with SwiftUI’s animation clock without manual timers.
        TimelineView(.animation) { context in
            // Convert the current timestamp into a bounded phase [0, 2π).
            let phase = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 2.0 * .pi)
            MultiHelixContentView(marbleCount: marbleCount, lanes: lanes, phase: phase)
        }
    }
}

// MARK: - MultiHelixContentView

struct MultiHelixContentView<S: Shape>: View {
    /// The base shape used for each marble (e.g. `Circle()` by default).
    var shape: S

    /// Number of marbles across the canvas. Also influences vertical spacing,
    /// since both axes derive their step from this count.
    var marbleCount: Int = 10

    /// A list of vertical gradients—one per animated lane. Each lane receives
    /// a distinct phase offset so the motion is visually “multi-helix.”
    var lanes: [Gradient]

    var phase: TimeInterval

    /// Creates a multi-helix animation view.
    ///
    /// - Parameters:
    ///   - shape: The per-item shape to draw (defaults to `Circle()`).
    ///   - marbleCount: How many marbles to place across the canvas.
    ///   - lanes: Lane palette; one lane per gradient.
    init(_ shape: S = Circle(), marbleCount: Int, lanes: [Gradient], phase: TimeInterval) {
        self.shape = shape
        self.marbleCount = marbleCount
        self.lanes = lanes
        self.phase = phase
    }

    var body: some View {
        Canvas { context, size in
            // For each lane and each marble rect, paint the shape with its
            // vertical linear gradient fill.
            for marble in marbles(in: size, phase: phase) {
                context.fill(marble.path, with: marble.shading)
            }
        }
        .aspectRatio(3.0 / 2.0, contentMode: .fit)
    }

    /// Computes all `Marble`s (one per marble per lane) for the current canvas size and phase.
    ///
    /// The phase for each lane is offset proportionally to its index:
    /// `basePhase + 2π * (laneIndex / laneCount)`.
    ///
    /// Marbles are finally sorted by area (ascending) to establish a stable painter’s order.
    private func marbles(in canvas: CGSize, phase: Double) -> [Marble<S>] {
        lanes.enumerated().lazy.map { offset, gradient in
            let lanePhase = phase + (2.0 * .pi) * (Double(offset) / Double(lanes.count))
            return marbleRects(in: canvas, phase: lanePhase).map { rect in
                Marble(shape: shape, rect: rect, gradient: gradient)
            }
        }
        .flatMap(\.self)
        .sorted(by: <)
    }

    /// Determines the layout rects for a single lane at a given phase.
    ///
    /// The canvas is divided into an `marbleCount × marbleCount` implicit grid;
    /// each column gets one marble. The horizontal step `dx` and vertical step `dy`
    /// both derive from `canvas / marbleCount`. Each marble’s:
    ///
    /// - **scale** varies with a cosine wave to emulate depth (0…1, then remapped to 0.5…1.0).
    /// - **vertical offset** varies with a sine wave so the lane appears to travel.
    /// - **horizontal position** stays near its column but compensates for scale so
    ///   smaller marbles remain visually centered within their slot.
    private func marbleRects(in canvas: CGSize, phase: Double) -> [CGRect] {
        let c = CGFloat(marbleCount)
        let dx = canvas.width / c
        let dy = canvas.height / c
        let r = min(dx, dy)
        return stride(from: 0.0, to: c, by: 1.0).map { i in
            // Scale oscillates with cosine: [-1, 1] → [0, 1] → remap to [0.5, 1.0]
            var scale = 0.5 * (cos(phase + 2.0 * .pi * (i / c)) + 1.0)
            scale = 0.5 * (scale + 1)
            // Vertical travel uses sine: [-1, 1] → [0, 1]
            let offset = 0.5 * (sin(phase + 2.0 * .pi * (i / c)) + 1.0)

            var rect = CGRect(origin: .zero, size: CGSize(width: r, height: r))
            // Apply scale to the marble’s bounding rect.
            rect.size.width *= scale
            rect.size.height *= scale
            // Keep horizontally centered within its column while accounting for scale.
            rect.origin.x = dx * (i + 0.5 * (1.0 - scale)) + rect.size.width / 4.0
            // Move along the lane vertically according to the sine phase.
            rect.origin.y = dy * ((c - 1) * offset + 0.5 * (1.0 - scale))
            return rect
        }
    }
}

// MARK: - Marble

/// Draw unit for one shape instance (a “marble”) with its lane gradient and rect.
private struct Marble<S: Shape> {
    /// The geometric primitive for the marble (e.g. circle).
    var shape: S
    /// The marble’s drawing rect in canvas coordinates.
    var rect: CGRect
    /// The lane’s vertical gradient used to shade this marble.
    var gradient: Gradient

    /// Vertical linear gradient shading across the marble’s rect.
    var shading: GraphicsContext.Shading {
        GraphicsContext.Shading.linearGradient(
            gradient,
            startPoint: .init(x: .zero, y: rect.origin.y),
            endPoint: .init(x: .zero, y: rect.origin.y + rect.size.height)
        )
    }

    /// The path for the marble, derived from the shape within `rect`.
    nonisolated var path: Path {
        shape.path(in: rect)
    }

    /// Marbles sort by area (ascending). This establishes a deterministic
    /// painter’s order when drawing on the canvas.
    nonisolated static func < (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.rect.width * lhs.rect.height < rhs.rect.width * rhs.rect.height
    }
}

// MARK: - Preview

#Preview {
    /// Basic preview for manual QA:
    /// - Adjust the steppers to verify lane count and marble density.
    /// - Confirm that each additional lane is phase-shifted vs. the previous one.
    /// - Resize to ensure the 3:2 aspect ratio is respected.
    MultiHelixScreen()
}
