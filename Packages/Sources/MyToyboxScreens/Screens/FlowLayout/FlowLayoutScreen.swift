import SwiftUI

@Metadata(title: .screenFlowLayoutTitle, description: .screenFlowLayoutDescription, tags: [.layout])
struct FlowLayoutScreen: View {
    @State private var width: CGFloat = 180

    let languageTags: [String] = [
        "Objective-C",
        "Swift",
        "SwiftSwiftSwiftSwiftSwiftSwiftSwiftSwift",
        "Ruby", "Python", "JavaScript",
        "Java", "C++", "C#", "Go", "Kotlin", "Rust",
    ]

    var body: some View {
        VStack {
            Spacer()
            Slider(value: $width.animation(), in: 100 ... 360)
        }
        .background {
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
            .frame(maxWidth: width)
            .background(.pink.mix(with: .white, by: 0.5))
        }
        .padding(20)
    }
}

#Preview {
    FlowLayoutScreen()
}
