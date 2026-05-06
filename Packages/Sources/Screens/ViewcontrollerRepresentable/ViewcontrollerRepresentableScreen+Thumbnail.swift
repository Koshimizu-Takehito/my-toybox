import MyToyboxCore
import SwiftUI

public extension ViewcontrollerRepresentableScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "pencil.and.ruler.fill")
                .resizable()
                .scaledToFit()
                .padding(2 * geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.orange.gradient)
        }
    }
}

#Preview {
    ViewcontrollerRepresentableScreen.thumbnail
}
