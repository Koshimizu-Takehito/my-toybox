import SwiftUI

extension FlowDistortionScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Image("waterwheel", bundle: .module)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .layerEffect(shader(time: time), maxSampleOffset: .zero)
    }

    private static func shader(time: TimeInterval) -> Shader {
        ShaderFunction(library: .module, name: "FlowDistortion::main")(
            .float(time),
            .float(0.021), // distortionStrength
            .float(0.95), // damping
            .float(2.0), // noiseScale
            .boundingRect
        )
    }
}

// MARK: - Preview

#Preview {
    FlowDistortionScreen.thumbnail
}
