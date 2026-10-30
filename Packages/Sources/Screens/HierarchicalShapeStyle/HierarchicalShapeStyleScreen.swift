import MyToyboxCore
import SwiftUI

// MARK: - HierarchicalShapeStyleScreen

@Metadata(title: .screenHierarchicalShapeStyleTitle, description: .screenHierarchicalShapeStyleDescription, tags: [])
public struct HierarchicalShapeStyleScreen: View {
    public init() {}

    public var body: some View {
        // Picks the largest arrangement that fits: three blocks stacked on tall
        // screens, side by side on wide ones, and smaller text on short ones.
        ViewThatFits {
            VStack { samples }
                .font(.largeTitle)
            HStack(alignment: .top, spacing: 24) { samples }
                .font(.title2)
            VStack { samples }
                .font(.title)
            VStack { samples }
                .font(.title3)
        }
        .fontWeight(.heavy)
        .fontDesign(.monospaced)
        .padding()
    }

    @ViewBuilder
    private var samples: some View {
        TextSampleView(style: .foreground)
        TextSampleView(style: .mint)
        TextSampleView(style: linearGradient)
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
            Text(verbatim: "あのイーハトーヴォの")
                .foregroundStyle(.primary)
            Text(verbatim: "すきとおった風、")
                .foregroundStyle(.secondary)
            Text(verbatim: "祓辻飴葛蝸鯛驢赳曇危箸")
                .foregroundStyle(.tertiary)
            Text(verbatim: "1234567890")
                .foregroundStyle(.quaternary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(style)
    }
}

#Preview {
    HierarchicalShapeStyleScreen()
}
