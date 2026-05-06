import MyToyboxCore
import SwiftUI

public extension SpiralShaderScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let scale = 0.05 + (sin(time.truncatingRemainder(dividingBy: 2 * .pi)) + 1) / 2.0
        Rectangle()
            .colorEffect(.spiral(scale: scale))
            .foregroundStyle(.red.mix(with: .white, by: 0.3))
            .backgroundExtensionEffect()
    }
}

#Preview {
    SpiralShaderScreen.thumbnail
}
