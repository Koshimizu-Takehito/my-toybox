import SwiftUI

extension CircleSDF1Screen {
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .colorEffect(.circleSDF1(seconds: time))
                .padding(geometry.size.width / 10.0)
        }
    }
}

#Preview {
    CircleSDF1Screen.thumbnail
}
