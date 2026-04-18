import SwiftUI

extension HierarchicalShapeStyleScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Text("あのイーハトーヴォのすきとおった風")
                .font(.system(size: 0.24 * size))
                .bold()
                .monospacedDigit()
                .minimumScaleFactor(0.1)
                .foregroundStyle(linearGradient)
                .padding(0.12 * size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private static var linearGradient: LinearGradient {
        let colors: [Color] = [.blue, .purple]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

#Preview {
    HierarchicalShapeStyleScreen.thumbnail
}
