import SwiftUI

extension DateformatStyleScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "calendar")
                .resizable()
                .scaledToFit()
                .padding(geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.red.gradient)
        }
    }
}

#Preview {
    DateformatStyleScreen.thumbnail
}
