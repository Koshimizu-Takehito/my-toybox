import MyToyboxCore
import SwiftUI

public extension ReverseListScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let spacing = geometry.size.width / 20
            VStack(spacing: spacing) {
                Spacer()
                Group {
                    Text(verbatim: "Hello, world!")
                        .frame(maxWidth: .infinity)
                        .padding(spacing)
                        .background(.orange.mix(with: .red, by: 0.5).gradient)
                    Text(verbatim: "Hello, world!")
                        .frame(maxWidth: .infinity)
                        .padding(spacing)
                        .background(.mint.mix(with: .blue, by: 0.5).gradient)
                }
                .minimumScaleFactor(0.1)
                .clipShape(.rect(cornerRadius: spacing))
                .bold()
            }
            .padding(2 * spacing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
