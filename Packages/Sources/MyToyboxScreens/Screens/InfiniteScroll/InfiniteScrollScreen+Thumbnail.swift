import SwiftUI

extension InfiniteScrollScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            ItemView(number: 1)
                .padding(geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    InfiniteScrollScreen.thumbnail
}
