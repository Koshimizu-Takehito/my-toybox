import MyToyboxCore
import SwiftUI

// MARK: - WaveParticleScreen

@Metadata(title: .screenWaveParticleTitle, description: .screenWaveParticleDescription, tags: [.animation, .metal])
public struct WaveParticleScreen: View {
    public init() {}

    private let start = Date()

    public var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            Rectangle()
                .colorEffect(.waveParticle(time: time))
        }
        .backgroundExtensionEffect()
    }
}

extension Shader {
    static func waveParticle(time: TimeInterval) -> Self {
        let function = ShaderFunction(library: .screenModule, name: "WaveParticle::main")
        return function(.boundingRect, .float(time))
    }
}

#Preview {
    WaveParticleScreen()
}
