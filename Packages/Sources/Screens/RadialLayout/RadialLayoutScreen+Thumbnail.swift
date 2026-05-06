import MyToyboxCore
import SwiftUI

public extension RadialLayoutScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let count = 6.0
        RadialLayout {
            ForEach(Array(stride(from: 0, to: 6, by: 1.0)), id: \.self) {
                Circle()
                    .foregroundStyle(Color(hue: $0 / count, saturation: 0.5, brightness: 1))
            }
        }
        .padding(6)
    }
}
