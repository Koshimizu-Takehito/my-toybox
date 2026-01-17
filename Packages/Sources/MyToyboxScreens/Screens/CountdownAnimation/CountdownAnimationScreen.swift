// https://x.com/TAAT626/status/1895841081365053901
// https://gist.github.com/TAATHub/8f9e7d987c82ef0eea62d2e420d51144
import SwiftUI

/// A full-screen countdown timer with circular animation and tap-to-restart interaction.
///
/// - Displays a numeric countdown (e.g., 10 → 0) in the center.
/// - A circular ring around the number gradually erases as the countdown progresses.
/// - Tapping the view restarts the countdown animation.
@Metadata(title: "Countdown Animation", description: "カウントダウンアニメーション", tags: [.animation])
struct CountdownAnimationScreen: View {
    /// The countdown state and animation logic.
    @State private var viewModel = CountdownAnimationScreenViewModel()

    var body: some View {
        let radius = 120.0

        ZStack {
            // Countdown number (rounded up to avoid showing 0 prematurely)
            Text("\(Int(viewModel.count + 0.99))")
                .fontDesign(.rounded)
                .font(.system(size: 60, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .transaction {
                    // Disable animation if below threshold to prevent flicker
                    $0.animation = viewModel.count > 1 ? $0.animation : nil
                }
                .animation(.default, value: viewModel.count)

            // Circular tick marks masked by progress ring
            ZStack {
                ForEach(0 ..< 36, id: \.self) { angle in
                    Capsule()
                        .frame(width: 8, height: 24)
                        .offset(x: 0, y: radius - 12)
                        .rotationEffect(.degrees(Double(angle) * 10))
                }
            }
            .mask {
                Circle()
                    .trim(from: 0, to: degree)
                    .stroke(lineWidth: 48)
                    .frame(width: 2 * radius, height: 2 * radius)
                    .rotationEffect(.degrees(-95))
            }
        }
        .frame(width: 2 * radius, height: 2 * radius)
        .clipShape(.circle)
        .contentShape(.circle)
        .foregroundStyle(viewModel.count > 0 ? AnyShapeStyle(.foreground) : AnyShapeStyle(.red))
        .onTapGesture {
            Task { viewModel.restart() }
        }
        .task {
            viewModel.restart()
        }
    }

    /// The normalized progress (0.0 → 1.0) based on the fractional part of the countdown.
    private var degree: Double {
        1.0 - viewModel.count.truncatingRemainder(dividingBy: 1.0)
    }
}

#Preview {
    CountdownAnimationScreen()
}
