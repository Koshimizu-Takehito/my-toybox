import SwiftUI

// MARK: - FlowDistortionScreen

@Metadata(title: "Flow Distortion", description: "Flow Distortion シェーダ", tags: [.metal])
public struct FlowDistortionScreen: View {
    @State private var start = Date.now
    @State private var model = Model()

    public init() {}

    public var body: some View {
        VStack {
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSince(start)
                Image("waterwheel", bundle: .module)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .layerEffect(shader(time: time), maxSampleOffset: .zero)
            }
            Control(model: $model.animation())
                .padding()
        }
    }

    func shader(time: TimeInterval) -> Shader {
        ShaderFunction(library: .module, name: "FlowDistortion::main")(
            .float(time),
            .float(model.distortionStrength),
            .float(model.damping),
            .float(model.noiseScale),
            .boundingRect
        )
    }
}

private extension FlowDistortionScreen {
    struct Model {
        /// 歪みの強度。値が大きいほどflowの影響が強くなる
        var distortionStrength = 0.021
        /// 緩和係数。値が小さいほど歪みが早く減衰
        var damping = 0.95
        /// ノイズのスケール。curlNoiseの強度を調整
        var noiseScale = 2.0
    }

    struct Control: View {
        @Binding var model: Model

        var body: some View {
            VStack(alignment: .trailing) {
                Slider(value: $model.distortionStrength, in: 0.01 ... 0.03)
                Slider(value: $model.damping, in: 0.10 ... 1.00)
                Slider(value: $model.noiseScale, in: 1.0 ... 3.0)
                Divider()
                Button("Reset") { model = Model() }
            }
        }
    }
}

/// プレビュー用のコード。XcodeでViewを確認可能。
#Preview {
    FlowDistortionScreen()
}
