import SwiftUI

extension MonotoneMapScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        ColoredMapScreen.thumbnail(isScrolling: isScrolling, time: time)
            .saturation(0)
    }
}

#Preview {
    MonotoneMapScreen.thumbnail
}
