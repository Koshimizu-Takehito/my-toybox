import SwiftUI

// MARK: - SpiralShaderScreen

@Metadata(title: "Shader Spiral", description: "シェーダー関数で螺旋", tags: [.animation, .metal])
struct SpiralShaderScreen: View {
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date
                .timeIntervalSince(start)
            let scale = 0.3 + 6 * (sin(time) + 1) / 2
            Rectangle()
                .colorEffect(.spiral(scale: scale))
                .foregroundStyle(.red.mix(with: .white, by: 0.3))
                .ignoresSafeArea()
        }
    }
}

extension Shader {
    static func spiral(scale: Double) -> Self {
        let function = ShaderFunction(library: .module, name: "SpiralShader::main")
        return function(.boundingRect, .float(scale))
    }
}

#Preview {
    SpiralShaderScreen()
}
