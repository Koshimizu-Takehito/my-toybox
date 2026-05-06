import MyToyboxCore
import SwiftUI

public extension Meshgradient2Screen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        #if os(iOS)
        MeshView(
            id: .constant(.init()),
            isDotsHidden: .constant(true),
            offsets: .constant(.init(repeating: .zero, count: 25)),
            width: 3,
            height: 3,
            colors: [.black, .blue, .green]
        )
        #endif
    }
}

#Preview {
    Meshgradient2Screen.thumbnail
}
