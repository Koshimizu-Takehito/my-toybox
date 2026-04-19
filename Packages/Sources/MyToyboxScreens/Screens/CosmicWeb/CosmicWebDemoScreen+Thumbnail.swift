import SwiftUI

extension CosmicWebDemoScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Rectangle()
            .layerEffect(.cosmicWeb(time: 0), maxSampleOffset: .zero)
    }
}

// MARK: - Preview

#Preview {
    CosmicWebDemoScreen.thumbnail
}
