import SwiftUI

// MARK: - AppleLogoScreen

@Metadata(title: "Apple Logo", description: "Canvas を 画像でクリップ", tags: [])
struct AppleLogoScreen: View {
    var body: some View {
        MultiColorImage(image: .applelogo, colors: .rainbow)
            .frame(maxWidth: 360)
            .padding()
    }
}

// MARK: - MultiColorImage

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

private extension Image {
    static var applelogo: Self {
        Image(systemName: "applelogo")
    }
}

private extension [Color] {
    static let rainbow: Self = [
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
