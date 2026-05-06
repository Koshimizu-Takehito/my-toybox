import MyToyboxCore
import SwiftUI

public extension CollisionColorChangeScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Image(systemName: "playstation.logo")
                .resizable()
                .scaledToFit()
                .padding(0.08 * size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
        .background(.blue.gradient)
    }
}

// MARK: - Preview

#Preview {
    CollisionColorChangeScreen.thumbnail
}
