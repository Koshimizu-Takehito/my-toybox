import MyToyboxCore
import SwiftUI

public extension SolarSystem1Screen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        SolarSystem1Screen
            .thumbnail(label: "S", color: .red.mix(with: .orange, by: 0.2))
    }
}

public extension SolarSystem1Screen {
    static func thumbnail(label: Character, color: Color) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                Circle()
                    .stroke()
                    .frame(width: 0.75 * size)
                Text(String(label))
                    .bold()
                    .frame(width: size / 2.0, height: size / 2.0)
                    .background(color.gradient, in: .circle)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
    }
}

#Preview {
    SolarSystem1Screen.thumbnail
        .preferredColorScheme(.dark)
}
