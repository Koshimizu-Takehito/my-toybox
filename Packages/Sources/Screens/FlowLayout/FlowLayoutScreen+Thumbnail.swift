import MyToyboxCore
import SwiftUI

public extension FlowLayoutScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let languageTags: [String] = [
            "Swift", "Ruby", "Python",
            "Java", "C++", "C#", "Go", "Kotlin", "Rust",
        ]
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let width = geometry.size.width * (1 - 0.7 * (1 + sin(time.truncatingRemainder(dividingBy: 2 * .pi))) / 2.0)
            FlowLayout(vSpacing: 0.02 * size, hSpacing: 0.02 * size) {
                ForEach(languageTags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 0.08 * size))
                        .lineLimit(nil)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.white)
                        .padding(.vertical, 0.05 * size)
                        .padding(.horizontal, 0.05 * size)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 0.05 * size))
                }
            }
            .frame(maxWidth: width)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(0.08 * size)
            .background(.pink.mix(with: .white, by: 0.5))
        }
    }
}

#Preview {
    FlowLayoutScreen.thumbnail
}
