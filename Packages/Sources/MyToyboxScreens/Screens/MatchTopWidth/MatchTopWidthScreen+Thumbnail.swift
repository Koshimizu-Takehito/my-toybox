import SwiftUI

extension MatchTopWidthScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "ruler")
                .resizable()
                .scaledToFit()
                .padding(geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue.gradient)
        }
    }
}

#Preview {
    MatchTopWidthScreen.thumbnail
}
