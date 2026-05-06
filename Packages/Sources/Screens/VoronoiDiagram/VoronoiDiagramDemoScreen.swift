import MyToyboxCore
import SwiftUI

// MARK: - VoronoiDiagramDemoScreen1

@MainActor
@Metadata(title: .screenVoronoiEuclideanTitle, description: .screenVoronoiEuclideanDescription, tags: [.animation, .metal])
public struct VoronoiDiagramDemoScreen1: View {
    public init() {}

    public var body: some View {
        AnimatableShaderView(
            title: "Hello, voronoi diagram.",
            nameSpace: "VoronoiDiagramShadeder1"
        )
    }
}

// MARK: - VoronoiDiagramDemoScreen2

@MainActor
@Metadata(title: .screenVoronoiCustomMetricTitle, description: .screenVoronoiCustomMetricDescription, tags: [.animation, .metal])
public struct VoronoiDiagramDemoScreen2: View {
    public init() {}

    public var body: some View {
        AnimatableShaderView(
            title: "Hello, metric space.",
            nameSpace: "VoronoiDiagramShadeder2"
        )
    }
}

// MARK: - AnimatableShaderView

private struct AnimatableShaderView: View {
    var title: String
    var nameSpace: String

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
                .backgroundExtensionEffect()
        }
    }

    private func shader(time: TimeInterval) -> Shader {
        let function = ShaderFunction(library: .screenModule, name: "\(nameSpace)::main")
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
