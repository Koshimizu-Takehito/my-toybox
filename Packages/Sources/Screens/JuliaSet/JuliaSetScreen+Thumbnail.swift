import MyToyboxCore
import SwiftUI

public extension JuliaSetScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let scale = 6 + 3 * sin(time.truncatingRemainder(dividingBy: 2 * .pi))
        JuliaSetShaderView(
            scale: scale,
            constant: CGPoint(x: 0.3575, y: 0.3575),
            location: CGPoint(x: 0.075, y: 0.29)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    JuliaSetScreen.thumbnail
        .scaledToFit()
}
