import SwiftUI

struct ShaderTileScreen: View {
    @State private var start = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince(start)
            let scale = 1 + 10 * (sin(time) + 1)
            Rectangle()
                .colorEffect(shader(scale: scale))
                .foregroundStyle(.white)
                .ignoresSafeArea()
        }
    }

    func shader(scale: Double) -> Shader {
        let function = ShaderFunction(
            library: .default,
            name: "ShaderTile::main"
        )
        return function(.boundingRect, .float(scale))
    }
}

#Preview {
    ShaderTileScreen()
}
