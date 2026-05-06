import MyToyboxCore
import SwiftUI

public extension WaveParticleScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Rectangle()
            .colorEffect(.waveParticle(time: time))
    }
}

#Preview {
    WaveParticleScreen.thumbnail
}
