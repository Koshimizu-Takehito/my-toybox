import SwiftUI

extension OrbitingDotsLoaderDemoScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let sharedRotationAngle = 3 * time.truncatingRemainder(dividingBy: 2 * .pi)
        GeometryReader { geometry in
            let boxWidth = min(geometry.size.width, geometry.size.height)
            OrbitingDotsLayerView(
                sharedRotationAngle: sharedRotationAngle,
                orbitRadius: boxWidth / 6
            )
            .frame(width: boxWidth, height: boxWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    OrbitingDotsLoaderDemoScreen.thumbnail
}
