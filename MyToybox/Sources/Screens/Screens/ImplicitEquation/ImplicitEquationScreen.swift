import SwiftUI

struct ImplicitEquationScreen: View {
    /// a: Radial Freq (0...10)/
    @State private var radialFreq: Double = 1.0
    /// b: Mix Freq (0...10)/
    @State private var mixFreq: Double = 1.0
    /// Iso Level (-1...1)/
    @State private var isoLevel: Double = 0.0
    /// Zoom (0.01...1)/
    @State private var zoom: Double = 0.15

    var body: some View {
        VStack(alignment: .leading) {
            // Graphic area with shader
            GeometryReader {
                Rectangle().fill(style(size: $0.size))
            }
            .scaledToFit()
            .layerEffect(implicitShader, maxSampleOffset: .zero)

            Text("Implicit Equation Explorer")
                .font(.headline)
            Text("f(x, y) = sin(a · (x² + y²)) − cos(b · x · y)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            // Sliders
            Grid(alignment: .leading) {
                GridRow {
                    Text("Radial Freq")
                    Slider(value: $radialFreq, in: 0...10, step: 0.1)
                    Text(String(format: "%.1f", radialFreq))
                }
                GridRow {
                    Text("Mix Freq")
                    Slider(value: $mixFreq, in: 0...10, step: 0.1)
                    Text(String(format: "%.1f", mixFreq))
                }
                GridRow {
                    Text("Iso Level")
                    Slider(value: $isoLevel, in: -1...1, step: 0.01)
                    Text(String(format: "%.2f", isoLevel))
                }
                GridRow {
                    Text("Zoom")
                    Slider(value: $zoom, in: 0.01...1, step: 0.01)
                    Text(String(format: "%.2f", zoom))
                }
            }
            .monospacedDigit()
            Button("Reset") {
                radialFreq = 1.0
                mixFreq = 1.0
                isoLevel = 0.0
                zoom = 0.15
            }
        }
        .contentTransition(.numericText())
        .animation(.default, value: radialFreq + mixFreq + isoLevel + zoom)
        .padding()
        .cornerRadius(10)
        .tint(.blue)
    }

    /// Creates the implicit equation shader with parameters.
    var implicitShader: Shader {
        ShaderFunction(library: .default, name: "ImplicitEquation::main")(
            .float(Float(radialFreq)),
            .float(Float(mixFreq)),
            .float(Float(isoLevel)),
            .float(Float(zoom)),
            .boundingRect
        )
    }

    func style(size: CGSize) -> some ShapeStyle {
        let colors = stride(from: 0.0, to: 2.0, by: 1.0/7.0).map { hue in
            Color(hue: hue.truncatingRemainder(dividingBy: 1), saturation: 0.25, brightness: 1)
        }
        return RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 0,
            endRadius: min(size.width, size.height) / sqrt(2)
        )
    }
}

#Preview {
    ImplicitEquationScreen()
        .preferredColorScheme(.dark)
}
