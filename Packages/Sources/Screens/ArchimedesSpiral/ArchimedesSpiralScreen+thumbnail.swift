import MyToyboxCore
import SwiftUI

public extension ArchimedesSpiralScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        ArchimedesSpiralContent(time: 0)
    }
}

#Preview {
    ArchimedesSpiralScreen.thumbnail
}
