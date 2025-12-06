import SwiftUI

struct ContentTransitionScreen: View {
    @State var rating: Double = 0

    var body: some View {
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
        .font(Font.system(size: 80).monospacedDigit().bold())
    }
}

#Preview {
    ContentTransitionScreen()
}
