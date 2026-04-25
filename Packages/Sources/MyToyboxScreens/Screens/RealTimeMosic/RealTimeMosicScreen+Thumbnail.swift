import SwiftUI

extension RealTimeMosicScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image("waterwheel", bundle: .module)
            .resizable()
            .scaledToFill()
            .layerEffect(.mosic, maxSampleOffset: CGSize(width: 4, height: 4))
    }
}

private extension Shader {
    static var mosic: Self {
        let function = ShaderFunction(library: .module, name: "RealTimeMosicShader::main")
        return function(.boundingRect, .float(4.0), .float(1.0))
    }
}

// MARK: - Preview

#Preview {
    RealTimeMosicScreen.thumbnail
}
