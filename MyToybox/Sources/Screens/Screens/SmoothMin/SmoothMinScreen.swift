import SwiftUI

struct SmoothMinScreen: View {
    @State private var value: Double = 0.8

    private let start = Date()
    private let shader = ShaderFunction(library: .default, name: "SmoothMin2d::main")

    var body: some View {
        ZStack {
            TimelineView(.animation) { context in
                let seconds = context.date.timeIntervalSince(start)
                Rectangle()
                    .colorEffect(
                        shader(
                            .boundingRect, // box
                            .float(seconds), // sec
                            .float(value) // k
                        )
                    )
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Slider(value: $value, in: 0...1)
                    .tint(.pink)
            }
            .padding(20)
        }
    }
}

#Preview {
    SmoothMinScreen()
}
