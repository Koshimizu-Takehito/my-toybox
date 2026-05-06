import MyToyboxCore
import SwiftUI

public extension UnevenRoundedRectangle2Screen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Text(verbatim: "Hello!")
                .bold()
                .minimumScaleFactor(0.1)
                .foregroundStyle(.white)
                .padding(0.2 * geometry.size.width)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.mint.gradient)
                .clipShape(.rect(topLeadingRadius: 0.16 * geometry.size.width))
                .padding(0.1 * geometry.size.width)
        }
    }
}

#Preview {
    UnevenRoundedRectangle2Screen.thumbnail
}
