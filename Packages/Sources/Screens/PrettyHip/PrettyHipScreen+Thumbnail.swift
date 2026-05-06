import MyToyboxCore
import SwiftUI

public extension PrettyHipScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let elapsed = time.truncatingRemainder(dividingBy: 2.0 * .pi)
        Rectangle()
            .foregroundStyle(.white)
            .colorEffect(.prettyHip(elapsed: elapsed))
    }
}

#Preview {
    PrettyHipScreen.thumbnail
}
