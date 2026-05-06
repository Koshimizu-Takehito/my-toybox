import MyToyboxCore
import MyToyboxMedia
import SwiftUI

public extension ProgressiveBlurScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image("waterwheel", bundle: MyToyboxMedia.bundle)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(ProgressiveBlur(radius: 0.2 * geometry.size.width))
        }
    }
}

#Preview {
    ProgressiveBlurScreen.thumbnail
}
