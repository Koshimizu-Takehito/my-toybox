import MyToyboxCore

// https://x.com/TAAT626/status/1895841081365053901
// https://gist.github.com/TAATHub/8f9e7d987c82ef0eea62d2e420d51144
import SwiftUI

// MARK: - CountdownAnimationScreen

/// A full-screen countdown timer with circular animation and tap-to-restart interaction.
///
/// - Displays a numeric countdown (e.g., 10 → 0) in the center.
/// - A circular ring around the number gradually erases as the countdown progresses.
/// - Tapping the view restarts the countdown animation.
@Metadata(title: .screenCountdownAnimationTitle, description: .screenCountdownAnimationDescription, tags: [.animation])
public struct CountdownAnimationScreen: View {
    public init() {}

    /// The countdown state and animation logic.
    @State private var viewModel = CountdownAnimationScreenViewModel()

    public var body: some View {
        CountdownAnimationView(count: viewModel.count)
            .onTapGesture(perform: viewModel.restart)
            .task(viewModel.restart)
    }
}

// MARK: - CountdownAnimationView

struct CountdownAnimationView: View {
    var count: Double = 10

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2.0

            ZStack {
                // Countdown number (rounded up to avoid showing 0 prematurely)
                Text(verbatim: "\(Int(count + 0.99))")
                    .fontDesign(.rounded)
                    .font(.system(size: 0.4 * radius, weight: .bold))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .transaction {
                        // Disable animation if below threshold to prevent flicker
                        $0.animation = count > 1 ? $0.animation : nil
                    }
                    .animation(.default, value: count)

                // Circular tick marks masked by progress ring
                ZStack {
                    ForEach(0 ..< 36, id: \.self) { angle in
                        Capsule()
                            .frame(width: radius / 20, height: 3 * radius / 20)
                            .offset(x: 0, y: 0.9 * radius)
                            .rotationEffect(.degrees(Double(angle) * 10))
                    }
                }
                .mask {
                    Circle()
                        .trim(from: 0, to: degree)
                        .stroke(lineWidth: 48)
                        .frame(width: 1.8 * radius, height: 1.8 * radius)
                        .rotationEffect(.degrees(-95))
                }
            }
            .frame(width: 2 * radius, height: 2 * radius)
            .clipShape(.circle)
            .contentShape(.circle)
            .foregroundStyle(count > 0 ? AnyShapeStyle(.foreground) : AnyShapeStyle(.red))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .scaledToFit()
    }

    /// The normalized progress (0.0 → 1.0) based on the fractional part of the countdown.
    private var degree: Double {
        1.0 - count.truncatingRemainder(dividingBy: 1.0)
    }
}

#Preview {
    CountdownAnimationScreen.thumbnail
}

#Preview {
    CountdownAnimationScreen()
}
