import SwiftUI

// MARK: - VoronoiDiagramDemoScreen

/// A demo screen that displays a real-time animated Voronoi diagram
/// using a custom Metal shader.
/// The diagram is rendered with an overlayed title.
struct VoronoiDiagramDemoScreen: View {
    var body: some View {
        VoronoiDiagramView()
    }
}

// MARK: - VoronoiDiagramView

/// A view that renders a Voronoi diagram using an animatable shader.
/// This view is internal to the demo screen.
private struct VoronoiDiagramView: View {
    var body: some View {
        AnimatableShaderView(
            title: "Hello, voronoi diagram.",
            shader: shader(time:)
        )
    }

    /// Returns a Shader configured with the current animation time.
    /// - Parameter time: The elapsed time in seconds since the animation started.
    /// - Returns: A `Shader` instance used for rendering the Voronoi diagram.
    private func shader(time: TimeInterval) -> Shader {
        // The Metal shader function name is intentionally "VoronoiDiagramShadeder::main".
        // Please ensure this name matches the function in your Metal library.
        let function = ShaderFunction(library: .default, name: "VoronoiDiagramShadeder::main")
        return function(.boundingRect, .float(time))
    }
}

// MARK: - AnimatableShaderView

/// A view that continuously animates a shader-based rendering using TimelineView.
/// Displays a central title overlay above the animated content.
private struct AnimatableShaderView: View {
    /// The title displayed over the animation.
    var title: String
    /// A closure that generates a `Shader` for a given elapsed time.
    var shader: (_ time: TimeInterval) -> Shader

    /// The reference date when the animation started.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            Rectangle()
                .colorEffect(shader(time))
                .overlay {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 30))
                        .shadow(radius: 1)
                        .shadow(radius: 2)
                        .shadow(radius: 3)
                        .shadow(radius: 4)
                        .shadow(radius: 5)
                }
                .ignoresSafeArea()
        }
    }
}

// MARK: - Preview

#Preview {
    VoronoiDiagramDemoScreen()
}
