import MyToyboxCore
import SwiftUI

public extension RinganimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let progress = (time / 4).truncatingRemainder(dividingBy: 1)
            RotatingProgressRingsView(progress: progress)
                .padding(0.16 * width)
                .frame(width: width)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    RinganimationScreen.thumbnail
}
