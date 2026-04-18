import SwiftUI

extension SpiralLayoutDemoScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        SpiralLayout {
            ForEach(0 ..< 9, id: \.self) { index in
                let hue = Double((index * 210) % 360) / 360
                return Color(hue: hue, saturation: 0.5, brightness: 1.0)
            }
        }
    }
}

#Preview {
    SpiralLayoutDemoScreen.thumbnail
}
