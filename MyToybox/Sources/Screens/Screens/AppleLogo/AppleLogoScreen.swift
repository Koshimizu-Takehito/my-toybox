import SwiftUI

struct AppleLogoScreen: View {
    var body: some View {
        MultiColorImage(image: .applelogo, colors: .rainbow)
            .frame(maxWidth: 360)
            .padding()
    }
}

struct MultiColorImage: View {
    var image: Image
    var colors: [Color]

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .hidden()
            .overlay(content: canvas)
    }

    @ViewBuilder
    func canvas() -> some View {
        Canvas { context, size in
            context.clipToLayer { context in
                context.draw(image, in: CGRect(origin: .zero, size: size))
            }
            var rect = CGRect(origin: .zero, size: size)
            rect.size.height = size.height / CGFloat(colors.count)
            for (offset, color) in colors.enumerated() {
                rect.origin.y = CGFloat(offset) * rect.size.height
                context.fill(Path(rect), with: .color(color))
            }
        }
    }
}

extension Image {
    fileprivate static var applelogo: Self {
        Image(systemName: "applelogo")
    }
}

extension [Color] {
    fileprivate static let rainbow: Self = [
        .green,
        .green,
        .green,
        .yellow,
        .orange,
        .red,
        .purple,
        .blue,
    ]
}

#Preview {
    AppleLogoScreen()
}
