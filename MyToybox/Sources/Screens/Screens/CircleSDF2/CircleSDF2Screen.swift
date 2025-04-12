import SwiftUI

/// A SwiftUI view that renders an animated visual using signed distance fields (SDFs) and a Metal shader.
///
/// This view displays two animated circles blended together using a smooth minimum function.
/// Users can control the animation phase and the blend factor (`k`) with sliders, and reset the animation using a button.
struct CircleSDF2Screen: View {
    /// The smoothing factor used in the `smoothMin` function inside the shader.
    @State private var k: Double = 0.36
    /// The phase of the animation (time value in radians).
    @State private var time: Double = .pi

    var body: some View {
        ZStack {
            // The shader background rendering area.
            Rectangle()
                .colorEffect(shader)

            // User controls: reset button and two sliders.
            VStack {
                Button("Reset", action: reset)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Controls the animation phase.
                Slider(value: $time, in: 0...(2.0 * .pi))

                // Controls the smoothing (blend sharpness).
                Slider(value: $k, in: 0...0.72)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            .padding(.bottom)
        }
        .animation(.default, value: k)
        .animation(.default, value: time)
        .ignoresSafeArea(edges: .all.subtracting(.top))
    }

    /// Constructs a shader using the current time and smoothing factor.
    private var shader: Shader {
        let function = ShaderFunction(
            library: .default,
            name: "CircleSDF2Shader::main"
        )
        return function(.boundingRect, .float(time), .float(k))
    }

    /// Resets the animation parameters to their default values.
    private func reset() {
        k = 0.36
        time = .pi
    }
}

#Preview {
    CircleSDF2Screen()
}
