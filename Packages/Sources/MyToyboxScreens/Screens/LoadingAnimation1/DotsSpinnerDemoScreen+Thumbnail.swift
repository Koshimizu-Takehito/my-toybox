import SwiftUI

extension DotsSpinnerDemoScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let phase = 3 * time.truncatingRemainder(dividingBy: 2 * .pi)
        let colors: [Color] = [.purple, .red, .yellow, .blue, .green]
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            DotsSpinnerContentView(colors: colors, phase: phase, side: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    DotsSpinnerDemoScreen.thumbnail
}
