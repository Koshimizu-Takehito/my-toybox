import SwiftUI

extension GradientPolygonScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            PolygonShape(vertex: 6, roundness: 0.5)
                .fill(gradient)
                .scaledToFit()
                .padding(0.04 * size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
    }
}

// MARK: - Preview

#Preview {
    GradientPolygonScreen.thumbnail
}
