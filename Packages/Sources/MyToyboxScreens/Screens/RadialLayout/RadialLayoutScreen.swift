import SwiftUI

@Metadata(title: .screenRadialLayoutTitle, description: .screenRadialLayoutDescription, tags: [.animation, .layout])
struct RadialLayoutScreen: View {
    private static let range = 3.0 ... 24.0
    @State private var count = Self.range.lowerBound
    @State private var new = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let phase = context.date.timeIntervalSince(new)
                .truncatingRemainder(dividingBy: 2.0 * .pi)
            RadialLayout {
                ForEach(Array(stride(from: 0, to: count, by: 1.0)), id: \.self) {
                    Circle().foregroundStyle(color(at: $0))
                }
            }
            .onChange(of: phase) { _, phase in
                withAnimation { count = count(at: phase) }
            }
        }
        .scaledToFit()
        .border(.red)
        .padding()
    }

    private func color(at index: Double) -> Color {
        Color(hue: index / count, saturation: 0.5, brightness: 1)
    }

    private func count(at phase: Double) -> Double {
        let a = Self.range.upperBound - Self.range.lowerBound
        let b = Self.range.lowerBound
        let x = (sin(phase) + 1) / 2
        return a * x + b
    }
}

#Preview {
    RadialLayoutScreen()
}
