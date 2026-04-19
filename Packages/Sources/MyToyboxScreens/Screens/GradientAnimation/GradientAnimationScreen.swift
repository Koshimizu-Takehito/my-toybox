import SwiftUI

// MARK: - GradientAnimationScreen

@Metadata(title: "GradientAnimation", description: "グラデーションアニメーション", tags: [.animation])
struct GradientAnimationScreen: View {
    private let startDate = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(startDate)
            ContentView(time: time)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
        }
    }
}

// MARK: GradientAnimationScreen.ContentView

extension GradientAnimationScreen {
    struct ContentView: View {
        var time: TimeInterval

        var body: some View {
            Image(systemName: "apple.logo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(rainbow(at: time))
                .scaleEffect(0.1 * sin(time) + 1)
        }

        private func rainbow(at time: TimeInterval) -> some ShapeStyle {
            LinearGradient(
                colors: .rainbow(hue: time / 5, count: 256).reversed(),
                startPoint: .topTrailing,
                endPoint: .bottom
            )
        }
    }
}

private extension [Color] {
    static func rainbow(hue: Double = 0, count: Int) -> Self {
        (0 ..< count).map { i in
            var value = hue + Double(i) / Double(count)
            value -= floor(value)
            return Color(hue: value, saturation: 1 / 4, brightness: 1)
        }
    }
}

#Preview {
    GradientAnimationScreen()
}
