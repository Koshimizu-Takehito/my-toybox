import SwiftUI

extension AppleLogoScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            MultiColorImage.appleLogoRainbow()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(0.08 * size)
        }
    }
}

#Preview {
    AppleLogoScreen.thumbnail
}
