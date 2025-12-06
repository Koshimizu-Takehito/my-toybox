import SwiftUI

/// A demo screen that applies a **Kuwahara** edge-preserving smoothing filter to an image
/// using a custom SwiftUI layer shader backed by Metal.
///
/// The filter selects, for each pixel, the mean color from the quadrant (among four
/// axis-aligned neighborhoods) with the **lowest luminance variance**, which tends to
/// preserve edges while smoothing within regions.
///
/// - User-controlled parameters:
///   - `radius`: Integer sampling radius for quadrant aggregation. The shader clamps
///     the effective radius to the range **[1, 16]**; the UI allows `0...6`, but `0` is
///     treated as **1** inside the shader.
///   - `blend`: Linear mix between the original color (`0.0`) and the filtered color (`1.0`).
///
/// - Implementation notes:
///   - The shader entry point is `Kuwahara::main` in the accompanying `.metal` file.
///   - `layerEffect(_:maxSampleOffset:)` uses `.zero` because the shader clamps all
///     sample coordinates to the layer’s bounds; no off-rect sampling occurs.
///   - This file adds documentation only; there are no behavioral changes.
struct KuwaharaScreen: View {
    /// Sampling radius used by the Kuwahara filter.
    /// - Note: The shader clamps the final radius to **[1, 16]**. A UI value of `0`
    ///   results in an effective radius of **1**. Use `blend = 0` to bypass the effect.
    @State private var radius: Int = 4

    /// Linear mix factor between the original image and the filtered result.
    /// `0.0` shows the original, `1.0` shows the full Kuwahara output.
    @State private var blend: Double = 1.0

    var body: some View {
        VStack {
            Spacer()
            contentView()
            Spacer()
            controlPanel()
        }
        .padding()
    }

    @ViewBuilder
    private func contentView() -> some View {
        // Shows a filtered image (top) and the original (bottom) for side-by-side comparison.
        // The filtered image uses the custom Kuwahara layer shader with the current
        // `radius` and `blend` values.
        VStack {
            Spacer()
            Image("waterwheel", bundle: .module)
                .resizable()
                .scaledToFit()
                .layerEffect(.kuwahara(radius: radius, blend: blend), maxSampleOffset: .zero)
            Text("Kuwahara filter")
            Spacer()
            Image("waterwheel", bundle: .module)
                .resizable()
                .scaledToFit()
            Text("Original")
            Spacer()
        }
        .font(.footnote)
    }

    @ViewBuilder
    private func controlPanel() -> some View {
        // Interactive controls for the filter:
        // - A `Stepper` for `radius` in `0...6` (the shader clamps to `[1, 16]`).
        // - A `Slider` for `blend` in `0...1`.
        // Use `blend = 0` to fully bypass the effect without changing the radius.
        VStack {
            HStack {
                Stepper(value: $radius, in: 0...6) {
                    Text("Radius \(radius.formatted())")
                }
            }
            HStack {
                Text("Blend \(blend, specifier: "%.2f")")
                Slider(value: $blend, in: 0...1)
            }
        }
        .fontDesign(.monospaced)
    }
}

extension Shader {
    /// Builds a SwiftUI `Shader` that invokes the `Kuwahara::main` Metal function.
    ///
    /// - Parameters:
    ///   - radius: Integer sampling radius (UI-level). The shader clamps to `[0, 6]`.
    ///   - blend: Mix factor between the source and filtered color in `[0, 1]`.
    /// - Returns: A `Shader` suitable for `layerEffect(_:maxSampleOffset:)`.
    fileprivate static func kuwahara(radius: Int, blend: Double) -> Self {
        let function = ShaderFunction(library: .module, name: "Kuwahara::main")
        return function(.float(Float(radius)), .boundingRect, .float(Float(blend)))
    }
}

#Preview {
    KuwaharaScreen()
}
