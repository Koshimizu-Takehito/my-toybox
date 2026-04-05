import SwiftUI

/// PrettyHip screen demonstrating a custom visual effect.
@Metadata(title: "PrettyHip", description: "PrettyHip", tags: [.animation, .metal])
public struct PrettyHipScreen: View {
    private let startDate = Date()
    private let shader = ShaderFunction(library: .module, name: "prettyHip")

    public init() {}

    public var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)

            Rectangle()
                .foregroundStyle(.white)
                .colorEffect(shader(.boundingRect, .float(elapsed)))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    PrettyHipScreen()
}
