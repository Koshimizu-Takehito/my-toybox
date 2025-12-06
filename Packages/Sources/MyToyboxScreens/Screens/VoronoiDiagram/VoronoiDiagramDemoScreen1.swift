import SwiftUI

// MARK: - VoronoiDiagramDemoScreen1

/// A demo screen that displays a real-time animated Voronoi diagram
/// using a custom Metal shader.
/// The diagram is rendered with an overlayed title.
struct VoronoiDiagramDemoScreen1: View {
    var body: some View {
        AnimatableShaderView(
            title: "Hello, voronoi diagram.",
            nameSpace: "VoronoiDiagramShadeder1"
        )
    }
}

// MARK: - VoronoiDiagramDemoScreen2

struct VoronoiDiagramDemoScreen2: View {
    var body: some View {
        AnimatableShaderView(
            title: "Hello, metric space.",
            nameSpace: "VoronoiDiagramShadeder2"
        )
    }
}

// MARK: - AnimatableShaderView

/// A view that continuously animates a shader-based rendering using TimelineView.
/// Displays a central title overlay above the animated content.
private struct AnimatableShaderView: View {
    /// The title displayed over the animation.
    var title: String
    /// A closure that generates a `Shader` for a given elapsed time.
    var nameSpace: String

    /// The reference date when the animation started.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            Rectangle()
                .colorEffect(shader(time: time))
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

    /// Returns a Shader configured with the current animation time.
    /// - Parameter time: The elapsed time in seconds since the animation started.
    /// - Returns: A `Shader` instance used for rendering the Voronoi diagram.
    private func shader(time: TimeInterval) -> Shader {
        let function = ShaderFunction(library: .module, name: "\(nameSpace)::main")
        return function(.boundingRect, .float(time))
    }
}

// MARK: - Preview

#Preview("Voronoi Diagram") {
    VoronoiDiagramDemoScreen1()
}

#Preview("Custom Metric Space") {
    VoronoiDiagramDemoScreen2()
}
