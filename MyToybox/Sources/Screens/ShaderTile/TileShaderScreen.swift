import SwiftUI

// MARK: - TileShaderScreen

/// A SwiftUI view that demonstrates a dynamic checkerboard pattern using a custom Metal shader.
///
/// The shader applies a tile-based color effect that animates over time by modulating the scale.
///
/// The screen uses a `TimelineView` to update continuously with animation timing.
struct TileShaderScreen: View {
    /// The reference timestamp used to calculate elapsed animation time.
    @State private var start = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate the time elapsed since view appearance.
            let time = context.date.timeIntervalSince(start)
            // Compute the scale factor, oscillating smoothly with a sine wave.
            let scale = 1 + 10 * (sin(time) + 1)

            Rectangle()
                .colorEffect(shader(scale: scale))
                .foregroundStyle(.blue.mix(with: .white, by: 0.3))
                .ignoresSafeArea()
        }
    }

    /// Returns a Metal-based shader with a dynamically adjustable tile scale.
    ///
    /// - Parameter scale: The zoom level of the checkerboard pattern.
    /// - Returns: A `Shader` configured with the current scale.
    func shader(scale: Double) -> Shader {
        let function = ShaderFunction(
            library: .default,
            name: "TileShader::main"
        )
        return function(.boundingRect, .float(scale))
    }
}

// MARK: - Preview

#Preview {
    TileShaderScreen()
}
