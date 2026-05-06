import MyToyboxCore
import SwiftUI

public extension Motions4Screen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        #if os(iOS)
        Content01(#colorLiteral(red: 0.8549019608, green: 0.2549019608, blue: 0.4039215686, alpha: 1), #colorLiteral(red: 1, green: 0.8392156863, blue: 0.2235294118, alpha: 1), progress: 1.0)
        #endif
    }
}
