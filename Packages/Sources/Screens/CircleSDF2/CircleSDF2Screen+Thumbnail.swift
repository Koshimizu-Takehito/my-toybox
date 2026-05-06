import SwiftUI

public extension CircleSDF2Screen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            Rectangle().colorEffect(.circleSDF2(time: time, k: 0.36))
                .padding(geometry.size.width / 10)
        }
    }
}

#Preview {
    CircleSDF2Screen.thumbnail
}
