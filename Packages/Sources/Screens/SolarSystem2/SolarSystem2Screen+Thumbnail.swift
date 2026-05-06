import MyToyboxCore
import Screen_SolarSystem1
import SwiftUI

public extension SolarSystem2Screen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        SolarSystem1Screen
            .thumbnail(label: "E", color: .blue.mix(with: .green, by: 0.2))
    }
}

#Preview {
    SolarSystem2Screen.thumbnail
        .preferredColorScheme(.dark)
}
