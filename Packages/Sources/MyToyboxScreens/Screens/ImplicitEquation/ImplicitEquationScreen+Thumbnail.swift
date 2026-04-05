import SwiftUI

extension ImplicitEquationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let implicitShader = ShaderFunction(library: .module, name: "ImplicitEquation::main")(
            .float(1.0), // radialFreq
            .float(1.0), // mixFreq
            .float(0.0), // isoLevel
            .float(0.15), // zoom
            .boundingRect
        )
        GeometryReader {
            Rectangle().fill(style(size: $0.size))
        }
        .scaledToFit()
        .layerEffect(implicitShader, maxSampleOffset: .zero)
    }

    private static func style(size: CGSize) -> some ShapeStyle {
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
}
