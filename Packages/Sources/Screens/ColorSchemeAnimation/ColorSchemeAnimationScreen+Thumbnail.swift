import MyToyboxCore
import SwiftUI

public extension ColorSchemeAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "sun.max.circle")
                .resizable()
                .scaledToFit()
                .padding(2 * geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.gradient)
        }
    }
}

#Preview {
    ColorSchemeAnimationScreen.thumbnail
}
