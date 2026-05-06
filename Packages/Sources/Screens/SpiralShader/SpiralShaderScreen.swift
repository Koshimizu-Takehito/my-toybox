import MyToyboxCore
import SwiftUI

// MARK: - SpiralShaderScreen

@Metadata(title: .screenSpiralShaderTitle, description: .screenSpiralShaderDescription, tags: [.animation, .metal])
public struct SpiralShaderScreen: View {
    public init() {}

    @State private var start = Date()

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date
                .timeIntervalSince(start)
            let scale = 0.3 + 6 * (sin(time) + 1) / 2
            Rectangle()
                .colorEffect(.spiral(scale: scale))
                .foregroundStyle(.red.mix(with: .white, by: 0.3))
                .backgroundExtensionEffect()
        }
    }
}

extension Shader {
    static func spiral(scale: Double) -> Self {
        let function = ShaderFunction(library: .screenModule, name: "SpiralShader::main")
        return function(.boundingRect, .float(scale))
    }
}

#Preview {
    SpiralShaderScreen()
}
