import SwiftUI

/// A SwiftUI view that renders a dynamic circle animation using a Metal shader.
///
/// The view uses `TimelineView` with `.animation` schedule to update the shader in sync with time.
/// The shader renders animated signed distance fields (SDFs) of two moving circles
/// that blend together using a smooth minimum function.
struct CircleSDF1Screen: View {
    /// The reference time when the view appears. Used to calculate elapsed seconds.
    private let startTime = Date()

    var body: some View {
        TimelineView(.animation) { context in
            Rectangle()
                .colorEffect(shader(
                    seconds: context.date.timeIntervalSince(startTime)
                ))
        }
        .ignoresSafeArea(edges: .all.subtracting(.top))
    }

    /// Constructs a shader using the elapsed time in seconds as input.
    /// - Parameter seconds: The time interval since the view first appeared.
    /// - Returns: A `Shader` that applies a Metal function to the view's color.
    private func shader(seconds: TimeInterval) -> Shader {
        let function = ShaderFunction(
            library: .default,
            name: "CircleSDF1Shader::main"
        )
        return function(.boundingRect, .float(seconds))
    }
}

#Preview {
    CircleSDF1Screen()
}
