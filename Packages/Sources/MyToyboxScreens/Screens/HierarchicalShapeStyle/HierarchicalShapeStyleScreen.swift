import SwiftUI

// MARK: - HierarchicalShapeStyleScreen

@Metadata(title: "Hierarchical Style", description: "Hierarchical ShapeStyle", tags: [])
struct HierarchicalShapeStyleScreen: View {
    var body: some View {
        VStack {
            TextSampleView(style: .foreground)
            TextSampleView(style: .mint)
            TextSampleView(style: linearGradient)
        }
        .font(.largeTitle)
        .fontWeight(.heavy)
        .fontDesign(.monospaced)
    }

    var linearGradient: LinearGradient {
        .init(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - TextSampleView

private struct TextSampleView<Style: ShapeStyle>: View {
    let style: Style

    var body: some View {
        VStack(alignment: .leading) {
            Text("あのイーハトーヴォの")
                .foregroundStyle(.primary)
            Text("すきとおった風、")
                .foregroundStyle(.secondary)
            Text("祓辻飴葛蝸鯛驢赳曇危箸")
                .foregroundStyle(.tertiary)
            Text("1234567890")
                .foregroundStyle(.quaternary)
        }
        .foregroundStyle(style)
    }
}

#Preview {
    HierarchicalShapeStyleScreen()
}
