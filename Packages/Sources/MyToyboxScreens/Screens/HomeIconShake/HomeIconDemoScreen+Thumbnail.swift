import SwiftUI

extension HomeIconDemoScreen {
    static func thumbnail(isScrolling: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 0.7 * size, height: 0.7 * size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue.gradient)
                .modifier(JiggleModifier(isEnabled: !isScrolling))
        }
    }
}

// MARK: - Preview

#Preview {
    HomeIconDemoScreen.thumbnail
}
