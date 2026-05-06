import MyToyboxCore
import SwiftUI

public extension ColoredMapScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .padding(geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.purple.mix(with: .blue, by: 0.5).gradient)
        }
    }
}

#Preview {
    ColoredMapScreen.thumbnail
}
