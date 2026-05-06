import MyToyboxCore
import SwiftUI

public extension EnumPickerScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "list.triangle")
                .resizable()
                .scaledToFit()
                .padding(2 * geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.purple.gradient)
        }
    }
}
