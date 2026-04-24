import SwiftUI

// MARK: - SmoothMinScreen

@Metadata(title: .screenSmoothMinTitle, description: .screenSmoothMinDescription, tags: [.animation, .metal])
struct SmoothMinScreen: View {
    @State private var value: Double = 0.8
    private let start = Date()

    var body: some View {
        ZStack {
            TimelineView(.animation) { context in
                let seconds = context.date.timeIntervalSince(start)
                Rectangle()
                    .colorEffect(.smoothMin2d(k: value, time: seconds))
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                Slider(value: $value, in: 0 ... 1)
                    .tint(.pink)
            }
            .padding(20)
        }
    }
}

extension Shader {
    static func smoothMin2d(k: Double, time: Double) -> Shader {
        let shader = ShaderFunction(library: .module, name: "SmoothMin2d::main")
        return shader(
            .boundingRect, // box
            .float(time), // sec
            .float(k) // k
        )
    }
}

#Preview {
    SmoothMinScreen()
}
