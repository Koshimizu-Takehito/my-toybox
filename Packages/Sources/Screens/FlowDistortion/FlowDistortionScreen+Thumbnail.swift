import MyToyboxCore
import MyToyboxMedia
import SwiftUI

extension FlowDistortionScreen {
    @ViewBuilder
    public static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Image("waterwheel", bundle: MyToyboxMedia.bundle)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .layerEffect(shader(time: time), maxSampleOffset: .zero)
    }

    private static func shader(time: TimeInterval) -> Shader {
        ShaderFunction(library: .screenModule, name: "FlowDistortion::main")(
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
