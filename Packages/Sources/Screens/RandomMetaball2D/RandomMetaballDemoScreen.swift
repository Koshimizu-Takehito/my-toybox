import Combine
import MyToyboxCore
import SwiftUI

// MARK: - RandomMetaballDemoScreen

/// A demo screen showcasing the `RandomMetaball2DView`.
///
/// This screen expands to fill the entire safe area.
@Metadata(title: .screenRandomMetaballDemoTitle, description: .screenRandomMetaballDemoDescription, tags: [.animation])
public struct RandomMetaballDemoScreen: View {
    public init() {}

    public var body: some View {
        RandomMetaball2DView(particleCount: 50)
            .backgroundExtensionEffect()
    }
}

// MARK: - RandomMetaball2DView

/// A view that displays a glowing "metaball" particle effect with randomized circles.
///
/// Particles appear at random locations and sizes. Their visibility
/// toggles in a staggered animation, producing a soft violet blending effect
/// where they overlap.
///
/// This effect uses a `Canvas` with `symbol` rendering for efficient GPU batching,
/// and applies alpha thresholding and blur filters for a glowing appearance.
struct RandomMetaball2DView: View {
    /// An array of scale factors (0 or 1) representing particle visibility.
    @State private var scales: [Double]

    /// The normalized geometry of each particle, generated once so that
    /// resizing the view rescales the particles instead of rerandomizing them.
    @State private var particles: [MetaballParticle]

    /// A timer that triggers an update cycle every 4 seconds.
    @State private var timer = Timer.publish(every: 4, on: .main, in: .common)
        .autoconnect()

    /// Creates a new particle view with a specified number of particles.
    ///
    /// - Parameter particleCount: The number of particles to display.
    init(particleCount count: Int) {
        _scales = .init(initialValue: .init(repeating: 0, count: count))
        _particles = .init(initialValue: (0 ..< count).map { _ in .random() })
    }

    var body: some View {
        RandomMetaballCanvas(scales: scales, particles: particles)
            .onAppear {
                Task {
                    update()
                }
            }
            .onReceive(timer) { _ in
                update()
            }
    }

    /// Updates the particle scales with random animation parameters.
    ///
    /// Each particle either expands or shrinks with a randomly chosen animation curve and delay.
    private func update() {
        var randomAnimation: Animation {
            .easeInOut(duration: .random(in: 1 ... 4))
                .delay(.random(in: 0 ... 2))
        }
        for idx in scales.indices {
            withAnimation(randomAnimation) {
                scales[idx] = (scales[idx] == 0) ? 1 : 0
            }
        }
    }
}

// MARK: - RandomMetaballCanvas

/// A canvas that renders metaball-like glowing particles
/// using SwiftUI's `Canvas` and symbol rendering.
struct RandomMetaballCanvas: View {
    /// The current scaling states of all particles.
    var scales: [Double]

    /// The normalized geometry of all particles.
    var particles: [MetaballParticle]

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Apply a purple alpha-threshold filter to define glow boundaries.
                context.addFilter(.alphaThreshold(min: 0.3, color: .purple))
                // Apply a slight blur to soften particle edges.
                context.addFilter(.blur(radius: 0.025 * min(size.width, size.height)))

                context.drawLayer { layer in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    for index in scales.indices {
                        layer.draw(layer.resolveSymbol(id: index)!, at: center)
                    }
                }
            } symbols: {
                let size = geometry.size
                let base = min(size.width, size.height)
                ForEach(scales.indices, id: \.self) { index in
                    let particle = particles[index]
                    Circle()
                        .frame(
                            width: particle.widthRatio * base,
                            height: particle.heightRatio * base
                        )
                        .position(
                            x: particle.xRatio * size.width,
                            y: particle.yRatio * size.height
                        )
                        .scaleEffect(scales[index])
                        .tag(index)
                }
            }
        }
    }
}

// MARK: - MetaballParticle

/// The geometry of a single particle, normalized to the canvas size.
///
/// Positions are relative to the canvas width / height, and diameters are
/// relative to the shorter side of the canvas.
struct MetaballParticle {
    var xRatio: CGFloat
    var yRatio: CGFloat
    var widthRatio: CGFloat
    var heightRatio: CGFloat

    static func random() -> Self {
        Self(
            xRatio: .random(in: 0 ... 1),
            yRatio: .random(in: 0 ... 1),
            widthRatio: .random(in: 0.025 ... 0.4),
            heightRatio: .random(in: 0.025 ... 0.4)
        )
    }
}

// MARK: - Preview

#Preview {
    RandomMetaballDemoScreen()
}
