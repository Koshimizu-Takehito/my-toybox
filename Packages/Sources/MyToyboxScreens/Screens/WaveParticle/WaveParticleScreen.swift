import SwiftUI

// MARK: - WaveParticleScreen

@Metadata(title: "WaveParticle", description: "MSLでパーティクル", tags: [.animation, .metal])
struct WaveParticleScreen: View {
    private let start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            Rectangle()
                .colorEffect(.waveParticle(time: time))
        }
        .ignoresSafeArea()
    }
}

extension Shader {
    static func waveParticle(time: TimeInterval) -> Self {
        let function = ShaderFunction(library: .module, name: "WaveParticle::main")
        return function(.boundingRect, .float(time))
    }
}

#Preview {
    WaveParticleScreen()
}
