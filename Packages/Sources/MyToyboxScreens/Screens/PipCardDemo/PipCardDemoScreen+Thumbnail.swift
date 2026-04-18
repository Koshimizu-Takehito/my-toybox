import SwiftUI

extension PipCardDemoScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Text("Drag me!")
                .foregroundColor(.white)
                .font(.system(size: 0.18 * size, weight: .bold))
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.blue.gradient)
    }
}

// MARK: - Preview

#Preview {
    PipCardDemoScreen.thumbnail
}
