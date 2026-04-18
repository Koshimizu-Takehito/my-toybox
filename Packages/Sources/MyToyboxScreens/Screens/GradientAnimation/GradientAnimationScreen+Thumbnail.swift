import SwiftUI

extension GradientAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            ContentView(time: 2 * time)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(0.1 * min(geometry.size.width, geometry.size.height))
        }
    }
}

#Preview {
    GradientAnimationScreen.thumbnail
}
