import SwiftUI

// MARK: - ShineScreen

/// A full-screen view that displays a shimmering animated visual effect
/// using a custom Metal shader and `TimelineView` to update the animation over time.
struct ShineScreen: View {
    /// The reference start time used to calculate animation progress.
    private let start = Date()

    /// A compiled Metal shader function that produces the shimmering effect.
    private let shader = ShaderFunction(library: .default, name: "Shine::main")

    var body: some View {
        // Continuously update the view using TimelineView to animate the shader with time
        TimelineView(.animation) { context in
            // Calculate the time elapsed since the view was created
            let seconds = context.date.timeIntervalSince(start)

            // Apply the Metal shader with a dynamic time-based parameter
            Rectangle()
                .colorEffect(shader(.boundingRect, .float(seconds)))
        }
        // Extend the effect to fill the entire screen
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    ShineScreen()
}
