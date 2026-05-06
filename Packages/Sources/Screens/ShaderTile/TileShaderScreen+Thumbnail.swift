import MyToyboxCore
import SwiftUI

public extension TileShaderScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        // Compute the scale factor, oscillating smoothly with a sine wave.
        let scale = 0.1 + (sin(time.truncatingRemainder(dividingBy: 2 * .pi)) + 1) / 2.0

        Rectangle()
            .colorEffect(.tile(scale: scale))
            .foregroundStyle(.blue.mix(with: .white, by: 0.3))
            .backgroundExtensionEffect()
    }
}

#Preview {
    TileShaderScreen.thumbnail
}
