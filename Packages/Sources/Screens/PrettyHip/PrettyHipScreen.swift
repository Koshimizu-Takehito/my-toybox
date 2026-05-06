import MyToyboxCore
import SwiftUI

// MARK: - PrettyHipScreen

/// PrettyHip screen demonstrating a custom visual effect.
@Metadata(title: .screenPrettyHipTitle, description: .screenPrettyHipDescription, tags: [.animation, .metal])
public struct PrettyHipScreen: View {
    public init() {}

    private let startDate = Date()

    public var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            Rectangle()
                .foregroundStyle(.white)
                .colorEffect(.prettyHip(elapsed: elapsed))
                .backgroundExtensionEffect()
        }
    }
}

extension Shader {
    static func prettyHip(elapsed: TimeInterval) -> Shader {
        let shader = ShaderFunction(library: .screenModule, name: "prettyHip")
        return shader(.boundingRect, .float(elapsed))
    }
}

#Preview {
    PrettyHipScreen()
}
