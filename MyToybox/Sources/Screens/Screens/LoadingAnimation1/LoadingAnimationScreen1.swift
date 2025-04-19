import SwiftUI

struct LoadingAnimationScreen1: View {
    @State var count: Int = 5
    let colors: [Color] = [.purple, .red, .yellow, .blue, .green, .brown, .cyan, .orange, .pink]

    var body: some View {
        VStack {
            LoadingView(colors: Array(colors[0..<count]))
                .frame(maxHeight: .infinity)
            Stepper(value: $count, in: 1...9) {
                Text("Colors")
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
            .padding()
        }
    }
}

struct LoadingView: View {
    var colors: [Color]
    var start = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                let count = colors.count
                ForEach(0..<count, id: \.self) { index in
                    let theta = 3 * context.date.timeIntervalSince(start)
                    let offset1: Double = Double(index) * (2 * .pi) / Double(count)
                    let offset2 = offset1 + (count % 2 == 0 ? Double.pi / Double(count) : Double.zero)
                    Dot(theta: theta, offset: offset1, color: colors[index], reverse: false)
                    Dot(theta: theta, offset: offset2, color: colors[index], reverse: true)
                }
            }
        }
        .padding()
        .frame(width: 340, height: 340)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 60))
        .scaledToFit()
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
