import SwiftUI

struct GradientAnimationScreen: View {
    private let startDate = Date()

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSince(startDate)
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(rainbow(at: time))
                    .scaleEffect(0.1 * sin(time) + 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
        .padding(40)
    }

    private func rainbow(at time: TimeInterval) -> some ShapeStyle {
        LinearGradient(
            colors: .rainbow(hue: time/5, count: 256).reversed(),
            startPoint: .topTrailing,
            endPoint: .bottom
        )
    }
}

private extension [Color] {
    static func rainbow(hue: Double = 0, count: Int) -> Self {
        (0..<count).map { i in
            var value = hue + Double(i) / Double(count)
            value -= floor(value)
            return Color(hue: value, saturation: 1/4, brightness: 1)
        }
    }
}

#Preview {
    GradientAnimationScreen()
}
