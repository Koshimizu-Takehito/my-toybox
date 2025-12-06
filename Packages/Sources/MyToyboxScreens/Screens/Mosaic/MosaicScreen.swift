import SwiftUI

/// A view that displays an animated mosaic effect applied to an image.
///
/// The mosaic is driven by a custom Metal shader and animated over time
/// using `TimelineView` with the `.animation` schedule.
///
/// The shader dynamically scales the mosaic blocks using a sine wave,
/// creating a smooth pulsating effect.
struct MosaicScreen: View {
    /// The reference start time used to calculate animation progress.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate the elapsed time since view appeared.
            let time = context.date.timeIntervalSince(start)

            // Compute the scale value for the mosaic effect.
            // Scale oscillates smoothly using a sine wave.
            let scale = scale(phase: time)
            Image("waterwheel", bundle: .module)
                .resizable()
                .padding(-scale / 2)
                .scaledToFit()
                .layerEffect(
                    mosaic(scale: scale),
                    maxSampleOffset: .init(width: scale, height: scale)
                )
                .mask {
                    Rectangle()
                }
        }
    }

    /// Creates a mosaic shader with a specified block scale.
    ///
    /// - Parameter scale: The size of each mosaic block in pixels.
    /// - Returns: A `Shader` that applies the mosaic effect.
    func mosaic(scale: Double) -> Shader {
        let function = ShaderFunction(
            library: .module,
            name: "Mosaic::main"
        )
        return function(.float(scale), .boundingRect)
    }

    func scale(phase: Double) -> Double {
        1 + 30 * (sin(phase) + 1) / 2
    }
}

#Preview {
    MosaicScreen()
}
