import SwiftUI

extension ShineScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Rectangle().colorEffect(.shine(time: time))
    }
}

#Preview {
    ShineScreen.thumbnail
}
