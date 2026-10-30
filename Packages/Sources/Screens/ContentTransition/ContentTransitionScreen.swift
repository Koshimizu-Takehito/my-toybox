import MyToyboxCore
import SwiftUI

@Metadata(title: .screenContentTransitionTitle, description: .screenContentTransitionDescription, tags: [])
public struct ContentTransitionScreen: View {
    public init() {}

    @State private var rating: Double = 0

    public var body: some View {
        // Steps the digits down on narrow columns instead of clipping them.
        ViewThatFits(in: .horizontal) {
            counter(fontSize: 80)
            counter(fontSize: 56)
            counter(fontSize: 40)
        }
        .padding()
    }

    private func counter(fontSize: CGFloat) -> some View {
        HStack(spacing: 18) {
            Button(
                action: { withAnimation { rating -= 1 } },
                label: { Image(systemName: "minus.circle") }
            )
            .disabled(rating <= 0)

            Text(String(describing: Int(rating)))
                .fixedSize()
                .contentTransition(.numericText(value: rating))

            Button(
                action: { withAnimation { rating += 1 } },
                label: { Image(systemName: "plus.circle") }
            )
            .disabled(rating >= 10)
        }
        .font(Font.system(size: fontSize).monospacedDigit().bold())
    }
}

#Preview {
    ContentTransitionScreen()
}
