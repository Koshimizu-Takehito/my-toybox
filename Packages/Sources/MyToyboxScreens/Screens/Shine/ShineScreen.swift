import SwiftUI

// MARK: - ShineScreen

/// A full-screen view that displays a shimmering animated visual effect
/// using a custom Metal shader and `TimelineView` to update the animation over time.
@Metadata(title: "Shine Shader", description: "シェーダーを使った光アニメーション", tags: [.animation, .metal])
struct ShineScreen: View {
    /// The reference start time used to calculate animation progress.
    private let start = Date()

    var body: some View {
        // Continuously update the view using TimelineView to animate the shader with time
        TimelineView(.animation) { context in
            // Calculate the time elapsed since the view was created
            let seconds = context.date.timeIntervalSince(start)

            // Apply the Metal shader with a dynamic time-based parameter
            Rectangle()
                .colorEffect(.shine(time: seconds))
        }
        // Extend the effect to fill the entire screen
        .ignoresSafeArea()
    }
}

extension Shader {
    /// A compiled Metal shader function that produces the shimmering effect.
    static func shine(time: TimeInterval) -> Self {
        let function = ShaderFunction(library: .module, name: "Shine::main")
        return function(.boundingRect, .float(time))
    }
}

// MARK: - Preview

#Preview {
    ShineScreen()
}
