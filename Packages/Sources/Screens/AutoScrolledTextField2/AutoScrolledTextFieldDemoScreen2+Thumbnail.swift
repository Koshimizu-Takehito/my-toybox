import MyToyboxCore
import SwiftUI

public extension AutoScrolledTextFieldDemoScreen2 {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .resizable()
            .scaledToFit()
            .padding(8)
    }
}
