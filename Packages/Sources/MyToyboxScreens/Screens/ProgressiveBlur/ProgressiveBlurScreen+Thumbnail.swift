import SwiftUI

extension ProgressiveBlurScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image("waterwheel", bundle: .module)
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
