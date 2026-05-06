import MyToyboxCore
import MyToyboxMedia
import SwiftUI

public extension KuwaharaScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image("waterwheel", bundle: MyToyboxMedia.bundle)
            .resizable()
            .scaledToFill()
            .layerEffect(.kuwahara(radius: 3, blend: 1.0), maxSampleOffset: .zero)
    }
}
