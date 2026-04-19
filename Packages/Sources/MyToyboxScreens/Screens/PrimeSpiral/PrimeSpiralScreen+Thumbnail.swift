import SwiftUI

extension PrimeSpiralScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let scale = 5 * (sin(time.truncatingRemainder(dividingBy: 2.0 * .pi)) + 1.6)
        PrimeSpiralContent(scale: scale, color: .yellow)
    }
}
