import SwiftUI

/// PrettyHip screen demonstrating a custom visual effect.
@Metadata(title: "PrettyHip", description: "PrettyHip", tags: [.animation, .metal])
struct PrettyHipScreen: View {
    private let startDate = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            Rectangle()
                .foregroundStyle(.white)
                .colorEffect(.prettyHip(elapsed: elapsed))
                .ignoresSafeArea()
        }
    }
}

extension Shader {
    static func prettyHip(elapsed: TimeInterval) -> Shader {
        let shader = ShaderFunction(library: .module, name: "prettyHip")
        return shader(.boundingRect, .float(elapsed))
    }
}

#Preview {
    PrettyHipScreen()
}
