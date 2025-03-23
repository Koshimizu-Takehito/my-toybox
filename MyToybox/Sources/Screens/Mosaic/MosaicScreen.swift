import SwiftUI

struct MosaicScreen: View {
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date
                .timeIntervalSince(start)
            let scale = 1 + 30 * (sin(time) + 1)
            Image("waterwheel")
                .resizable()
                .scaledToFit()
                .layerEffect(mosaic(scale: scale), maxSampleOffset: .zero)
        }
    }

    func mosaic(scale: Double) -> Shader {
        let function = ShaderFunction(
            library: .default,
            name: "Mosaic::main"
        )
        return function(.float(scale))
    }
}

#Preview {
    MosaicScreen()
}
