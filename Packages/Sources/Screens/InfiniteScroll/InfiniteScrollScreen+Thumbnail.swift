import MyToyboxCore
import SwiftUI

public extension InfiniteScrollScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        #if os(iOS)
        GeometryReader { geometry in
            ItemView(number: 1)
                .padding(geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #endif
    }
}

#Preview {
    InfiniteScrollScreen.thumbnail
}
