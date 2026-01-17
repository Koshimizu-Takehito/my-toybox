import SwiftUI

// MARK: - ProgressiveBlurScreen

/// A view that continuously animates a blur effect across a static image.
///
/// The blur radius changes over time using a sine wave,
/// and the effect is rendered using a custom Metal shader (`ProgressiveBlur::main`).
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
/// The shader will blur the image more toward the bottom of the view.
struct ProgressiveBlur: ViewModifier {
    /// The base blur radius applied in the shader.
    let radius: Double

    func body(content: Content) -> some View {
        // Define the maximum sampling offset needed based on blur radius.
        let offset = CGSize(width: radius, height: radius)

        // Load and configure the shader function.
        let function = ShaderFunction(
            library: .module,
            name: "ProgressiveBlur::main"
        )
        let shader = function(.boundingRect, .float(radius))

        // Apply the shader as a layer effect.
        content.layerEffect(shader, maxSampleOffset: offset)
    }
}

#Preview {
    ProgressiveBlurScreen()
}
