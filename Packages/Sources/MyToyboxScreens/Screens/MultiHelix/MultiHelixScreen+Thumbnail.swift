import SwiftUI

extension MultiHelixScreen {
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        MultiHelixContentView(
            marbleCount: 3,
            lanes: [
                [Color(red: 0.98, green: 0.57, blue: 0.16), Color(red: 0.95, green: 0.15, blue: 0.01)],
                [Color(red: 0.23, green: 0.77, blue: 1.00), Color(red: 0.02, green: 0.32, blue: 0.73)],
                [Color(red: 0.04, green: 1.00, blue: 0.52), Color(red: 0.10, green: 0.52, blue: 0.31)],
            ]
            .map(Gradient.init),
            phase: -time.truncatingRemainder(dividingBy: 2.0 * .pi)
        )
    }
}

#Preview {
    MultiHelixScreen.thumbnail
}
