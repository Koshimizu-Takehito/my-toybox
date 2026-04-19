import SwiftUI

extension ColorHexAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            Thumbnail(time: time, isScrolling: isScrolling)
                .padding(0.1 * geometry.size.width)
        }
    }

    private struct Thumbnail: View {
        /// The currently displayed color.
        @State private var currentColor: Color = makeRandomColor()
        /// The timestamp of the last color change.
        @State private var lastColorChangeDate: TimeInterval = .zero

        @Environment(\.self) var environment

        var time: TimeInterval

        var isScrolling: Bool

        var body: some View {
            ColorCircleView(color: currentColor, environment: environment)
                .animation(!isScrolling ? .linear(duration: 1) : nil, value: currentColor)
                .onChange(of: time, initial: true) { _, time in
                    if time - lastColorChangeDate > 1.8 {
                        lastColorChangeDate = time
                        currentColor = makeRandomColor()
                    }
                }
        }
    }
}

#Preview {
    ColorHexAnimationScreen.thumbnail
}
