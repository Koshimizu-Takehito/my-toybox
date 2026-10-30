import MyToyboxCore
import SwiftUI

@Metadata(title: .screenFlowLayoutTitle, description: .screenFlowLayoutDescription, tags: [.layout])
public struct FlowLayoutScreen: View {
    public init() {}

    /// The flow container width as a fraction of the canvas width.
    @State private var widthFraction: CGFloat = 0.5

    let languageTags: [String] = [
        "Objective-C",
        "Swift",
        "SwiftSwiftSwiftSwiftSwiftSwiftSwiftSwift",
        "Ruby", "Python", "JavaScript",
        "Java", "C++", "C#", "Go", "Kotlin", "Rust",
    ]

    public var body: some View {
        CanvasControlsStack(canvasAspectRatio: nil) {
            GeometryReader { proxy in
                flowLayout
                    .frame(maxWidth: widthFraction * proxy.size.width)
                    .background(.pink.mix(with: .white, by: 0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipped()
        } controls: {
            Slider(value: $widthFraction.animation(), in: 0.3 ... 1)
        }
    }

    private var flowLayout: some View {
        FlowLayout(vSpacing: 8.0, hSpacing: 8.0) {
            ForEach(languageTags, id: \.self) { tag in
                Text(tag)
                    .lineLimit(nil)
                    .font(.body)
                    .fontWeight(.semibold)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

#Preview {
    FlowLayoutScreen()
}
