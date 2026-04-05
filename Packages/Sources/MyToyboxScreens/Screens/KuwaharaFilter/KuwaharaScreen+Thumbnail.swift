import SwiftUI

extension KuwaharaScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image("waterwheel", bundle: .module)
            .resizable()
            .scaledToFill()
            .layerEffect(.kuwahara(radius: 3, blend: 1.0), maxSampleOffset: .zero)
    }
}
