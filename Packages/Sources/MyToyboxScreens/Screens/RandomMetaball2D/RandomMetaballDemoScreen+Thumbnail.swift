import SwiftUI

extension RandomMetaballDemoScreen {
    static func thumbnail(isScrolling: Bool, time _: TimeInterval) -> some View {
        RandomMetaball2DView(particleCount: 10)
            .id(isScrolling)
    }
}

#Preview {
    RandomMetaballDemoScreen.thumbnail
}
