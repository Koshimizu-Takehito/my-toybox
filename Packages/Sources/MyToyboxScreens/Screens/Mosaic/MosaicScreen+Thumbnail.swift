import SwiftUI

extension MosaicScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { _ in
            let scale: Double = 4
            Image("waterwheel", bundle: .module)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .layerEffect(.mosaic(scale: scale), maxSampleOffset: .init(width: scale, height: scale))
        }
    }
}

#Preview {
    MosaicScreen.thumbnail
}
