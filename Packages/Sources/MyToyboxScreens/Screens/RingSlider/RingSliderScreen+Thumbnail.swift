import SwiftUI

extension RingSliderScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let ratio = 0.0
        GeometryReader { geometry in
            ZStack {
                // Background color with hue rotation based on slider value
                Color(hue: 1, saturation: 0.3, brightness: 1)
                    .hueRotation(.degrees(360 * ratio))
                // The interactive ring slider
                RingSlider(ratio: .constant(ratio))
                    .frame(width: geometry.size.width * 0.8)
            }
            .tint(.blue)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    RingSliderScreen.thumbnail
}
