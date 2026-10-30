import MyToyboxCore
import MyToyboxMedia
import SwiftUI

public extension GameBoyMosaicScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image("waterwheel", bundle: MyToyboxMedia.bundle)
            .resizable()
            .scaledToFill()
            .gameBoyMosaic(size: 6, count: 16)
    }
}
