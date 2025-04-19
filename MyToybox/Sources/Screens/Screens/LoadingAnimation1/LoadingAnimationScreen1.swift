import SwiftUI

struct LoadingAnimationScreen1: View {
    let start = Date.now
    let colors: [Color] = [.purple, .red, .yellow, .blue, .green]

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                ForEach(0..<colors.count, id: \.self) { index in
                    let theta = 3 * context.date.timeIntervalSince(start)
                    let offset: Double = Double(index) * (2 * .pi) / Double(colors.count)
                    Dot(theta: theta, offset: offset, color: colors[index], reverse: true)
                    Dot(theta: theta, offset: offset, color: colors[index], reverse: false)
                }
            }
        }
    }
}

private struct Dot: View {
    var radius: Double = 60
    var theta: Double
    var offset: Double
    var color: Color
    var reverse = false

    var body: some View {
        let theta = reverse ? -(theta + .pi) : theta
        let scale = 0.5 + (abs((theta - .pi).remainder(dividingBy: 2 * .pi))) / (2 * .pi)
        Circle()
            .frame(width: 30)
            .scaleEffect(x: scale, y: scale)
            .offset(
                x: radius * (cos(theta + offset) + cos(offset)),
                y: radius * (sin(theta + offset) + sin(offset))
            )
            .foregroundStyle(color)
            .rotationEffect(reverse ? .radians(.pi) : .zero)
            .shadow(color: color.opacity(0.3), radius: 10, y: 30 * scale)
    }
}

#Preview {
    LoadingAnimationScreen1()
}
