import SwiftUI

@Metadata(title: "Implicit Equation", description: "陰関数 SDF", tags: [.animation, .metal])
struct ImplicitEquationScreen: View {
    private struct Ranges {
        let ab = 0.0 ... 10.0
        let iso = -1.0 ... 1.0
        let zoom = 0.01 ... 1.00
    }

    private let range = Ranges()
    /// a: Radial Freq (0...10)/
    @State private var radialFreq: Double = 1.0
    /// b: Mix Freq (0...10)/
    @State private var mixFreq: Double = 1.0
    /// Iso Level (-1...1)/
    @State private var isoLevel: Double = 0.0
    /// Zoom (0.01...1)/
    @State private var zoom: Double = 0.15

    var body: some View {
        let a = String(format: "%.1f", radialFreq)
        let b = String(format: "%.1f", mixFreq)

        VStack(alignment: .leading) {
            // Graphic area with shader
            GeometryReader {
                Rectangle().fill(style(size: $0.size))
            }
            .scaledToFit()
            .layerEffect(implicitShader, maxSampleOffset: .zero)

            Text("Implicit Equation Explorer")
                .font(.headline)
            Text("f(x,y) = sin(\(a)(x²+y²)) - cos(\(b)xy)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            // Sliders
            Grid(alignment: .leading) {
                GridRow {
                    Text("Radial Freq")
                    Slider(value: $radialFreq, in: range.ab, step: 0.1)
                    text(a)
                }
                GridRow {
                    Text("Mix Freq")
                    Slider(value: $mixFreq, in: range.ab, step: 0.1)
                    text(b)
                }
                GridRow {
                    Text("Iso Level")
                    Slider(value: $isoLevel, in: range.iso, step: 0.01)
                    text(String(format: "%.2f", isoLevel))
                }
                GridRow {
                    Text("Zoom")
                    Slider(value: $zoom, in: range.zoom, step: 0.01)
                    text(String(format: "%.2f", zoom))
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
        ShaderFunction(library: .module, name: "ImplicitEquation::main")(
            .float(radialFreq),
            .float(mixFreq),
            .float(isoLevel),
            .float(zoom),
            .boundingRect
        )
    }

    func style(size: CGSize) -> some ShapeStyle {
        let colors = stride(from: 0.0, to: 2.0, by: 1.0 / 7.0).map { hue in
            Color(hue: hue.truncatingRemainder(dividingBy: 1), saturation: 0.25, brightness: 1)
        }
        return RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 0,
            endRadius: min(size.width, size.height) / sqrt(2)
        )
    }

    @ViewBuilder
    func text(_ value: String) -> some View {
        ZStack(alignment: .trailing) {
            Text(value)
            Group {
                Text(String(format: "%.1f", range.ab.lowerBound))
                Text(String(format: "%.1f", range.ab.upperBound))
                Text(String(format: "%.2f", range.iso.lowerBound))
                Text(String(format: "%.2f", range.iso.upperBound))
                Text(String(format: "%.2f", range.zoom.lowerBound))
                Text(String(format: "%.2f", range.zoom.upperBound))
            }
            .hidden()
        }
    }
}

#Preview {
    ImplicitEquationScreen()
        .preferredColorScheme(.dark)
}
