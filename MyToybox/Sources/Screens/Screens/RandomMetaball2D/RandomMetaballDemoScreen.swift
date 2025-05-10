import Combine
import SwiftUI

// MARK: - Demo View

/// A demo screen showcasing the `RandomMetaball2DView`.
///
/// This screen expands to fill the entire safe area.
struct RandomMetaballDemoScreen: View {
    var body: some View {
        RandomMetaball2DView(particleCount: 50)
            .ignoresSafeArea()
    }
}

// MARK: - Random Metaball 2D View

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

    /// A timer that triggers an update cycle every 4 seconds.
    @State private var timer = Timer.publish(every: 4, on: .main, in: .common)
        .autoconnect()

    /// Creates a new particle view with a specified number of particles.
    ///
    /// - Parameter particleCount: The number of particles to display.
    init(particleCount count: Int) {
        _scales = .init(initialValue: .init(repeating: 0, count: count))
    }

    var body: some View {
        RandomMetaballCanvas(scales: scales)
            .onAppear {
                DispatchQueue.main.async {
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
            .easeInOut(duration: .random(in: 1...4))
            .delay(.random(in: 0...2))
        }
        for idx in scales.indices {
            withAnimation(randomAnimation) {
                scales[idx] = (scales[idx] == 0) ? 1 : 0
            }
        }
    }
}

// MARK: - Random Metaball Canvas

/// A canvas that renders metaball-like glowing particles
/// using SwiftUI's `Canvas` and symbol rendering.
struct RandomMetaballCanvas: View {
    /// The current scaling states of all particles.
    var scales: [Double]

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
                let maxWidth = 0.4 * min(size.width, size.height)
                ForEach(scales.indices, id: \.self) { index in
                    Circle()
                        .frame(
                            width: .random(in: 10...maxWidth),
                            height: .random(in: 10...maxWidth)
                        )
                        .position(
                            x: .random(in: 0...size.width),
                            y: .random(in: 0...size.height)
                        )
                        .scaleEffect(scales[index])
                        .tag(index)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RandomMetaballDemoScreen()
}
