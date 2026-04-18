import SwiftUI

extension SmoothMinScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Rectangle()
            .colorEffect(.smoothMin2d(k: 0.8, time: time))
    }
}

#Preview {
    SmoothMinScreen.thumbnail
}
