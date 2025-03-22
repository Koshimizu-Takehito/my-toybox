import SwiftUI

// https://x.com/TAAT626/status/1895841081365053901
// https://gist.github.com/TAATHub/8f9e7d987c82ef0eea62d2e420d51144
struct CountdownAnimationScreen: View {
    @State private var counter = Countdown()

    var body: some View {
        let radius = 120.0
        ZStack {
            Text("\(Int(counter.count + 0.99))")
                .fontDesign(.rounded)
                .font(.system(size: 60, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .transaction { $0.animation = counter.count > 1 ? $0.animation : nil }
                .animation(.default, value: counter.count)
            ZStack {
                ForEach(Array(0..<36), id: \.self) { angle in
                    Capsule()
                        .frame(width: 8, height: 24)
                        .offset(x: 0, y: radius - 24.0/2.0)
                        .rotationEffect(.degrees(Double(angle) * 10))
                }
            }
            .mask {
                Circle()
                    .trim(from: 0, to: degree)
                    .stroke(lineWidth: 2 * 24)
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(.degrees(-90.0 - 5.0))
            }
        }
        .frame(width: 2 * radius, height: 2 * radius)
        .clipShape(.circle)
        .contentShape(.circle)
        .foregroundStyle(counter.count > 0 ? AnyShapeStyle(.foreground) : AnyShapeStyle(.red))
        .onTapGesture {
            Task { await counter.restart() }
        }
    }

    private var degree: Double {
        1.0 - counter.count.truncatingRemainder(dividingBy: 1.0)
    }
}

#Preview {
    CountdownAnimationScreen()
}
