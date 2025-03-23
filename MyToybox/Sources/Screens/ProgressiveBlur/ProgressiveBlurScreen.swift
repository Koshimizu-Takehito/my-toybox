import SwiftUI

struct ProgressiveBlurScreen: View {
    let start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            let radius = 20 * (sin(time - .pi/2) + 1)
            Image("waterwheel")
                .resizable()
                .scaledToFit()
                .modifier(ProgressiveBlur(radius: radius))
        }
    }
}

struct ProgressiveBlur: ViewModifier {
    let radius: Double

    func body(content: Content) -> some View {
        let offset = CGSize(width: radius, height: radius)
        let function = ShaderFunction(
            library: .default,
            name: "ProgressiveBlur::main"
        )
        let shader = function(.boundingRect, .float(radius))
        content.layerEffect(shader, maxSampleOffset: offset)
    }
}

#Preview {
    ProgressiveBlurScreen()
}
