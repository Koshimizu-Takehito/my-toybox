import SwiftUI

// MARK: - ProgressiveBlurScreen

/// A view that continuously animates a blur effect across a static image.
///
/// The blur radius changes over time using a sine wave,
/// and the effect is rendered with `ProgressiveBlur::progressiveBlur1D` applied twice
/// (horizontal then vertical) via chained `.layerEffect` calls.
@Metadata(title: "Progressive Blur", description: "ProgressiveBlur", tags: [.metal])
struct ProgressiveBlurScreen: View {
    /// The reference start time of the animation.
    let start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            // Elapsed time since animation start
            let time = context.date.timeIntervalSince(start)

            // Blur radius oscillates between 0 and 40 using a sine wave.
            let radius = 20 * (sin(time - .pi / 2) + 1)

            Image("waterwheel", bundle: .module)
                .resizable()
                .scaledToFit()
                .modifier(ProgressiveBlur(radius: radius))
        }
    }
}

// MARK: - ProgressiveBlur

/// A custom view modifier that applies a progressive Gaussian blur
/// using a Metal shader. The blur radius can be dynamically adjusted.
///
/// Uses two separable 1D passes (horizontal then vertical) for O(r)+O(r)
/// performance instead of the O(r^2) cost of a single 2D convolution.
struct ProgressiveBlur: ViewModifier {
    /// The base blur radius applied in the shader.
    let radius: Double

    func body(content: Content) -> some View {
        let offset = CGSize(width: radius, height: radius)

        let fn = ShaderFunction(
            library: .module,
            name: "ProgressiveBlur::progressiveBlur1D"
        )
        let horizontal = fn(.boundingRect, .float(radius), .float(0))
        let vertical = fn(.boundingRect, .float(radius), .float(1))

        content
            .layerEffect(horizontal, maxSampleOffset: offset)
            .layerEffect(vertical, maxSampleOffset: offset)
    }
}

#Preview {
    ProgressiveBlurScreen()
}
