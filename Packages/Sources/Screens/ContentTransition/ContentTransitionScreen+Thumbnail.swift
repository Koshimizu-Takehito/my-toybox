import MyToyboxCore
import SwiftUI

public extension ContentTransitionScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let value = time.truncatingRemainder(dividingBy: 10)
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            Text(String(describing: Int(value)))
                .font(.system(size: 0.6 * size))
                .monospaced()
                .bold()
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(0.16 * size)
        }
        .contentTransition(.numericText(value: value))
        .animation(.default, value: value)
    }
}

#Preview {
    ContentTransitionScreen.thumbnail
}
