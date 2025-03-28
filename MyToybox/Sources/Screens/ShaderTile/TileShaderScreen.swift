import SwiftUI

struct TileShaderScreen: View {
    @State private var start = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            let scale = 1 + 10 * (sin(time) + 1)
            Rectangle()
                .colorEffect(shader(scale: scale))
                .foregroundStyle(.blue.mix(with: .white, by: 0.3))
                .ignoresSafeArea()
        }
    }

    func shader(scale: Double) -> Shader {
        let function = ShaderFunction(
            library: .default,
            name: "TileShader::main"
        )
        return function(.boundingRect, .float(scale))
    }
}

#Preview {
    TileShaderScreen()
}
