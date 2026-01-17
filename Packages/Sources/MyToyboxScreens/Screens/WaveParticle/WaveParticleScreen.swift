import SwiftUI

@Metadata(title: "WaveParticle", description: "MSLでパーティクル", tags: [.animation, .metal])
struct WaveParticleScreen: View {
    private let start = Date()

    var body: some View {
        let shader = ShaderFunction(library: .module, name: "WaveParticle::main")
        TimelineView(.animation) { context in
            let seconds = context.date.timeIntervalSince(start)
            Rectangle()
                .colorEffect(shader(.boundingRect, .float(seconds)))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WaveParticleScreen()
}
