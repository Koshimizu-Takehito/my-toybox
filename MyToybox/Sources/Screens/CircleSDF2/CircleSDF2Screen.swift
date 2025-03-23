import SwiftUI

struct CircleSDF2Screen: View {
    @State var k: Double = 0.36
    @State var time: Double = .pi

    var body: some View {
        ZStack {
            Rectangle()
                .colorEffect(shader)
            VStack {
                Button("Reset", action: reset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Slider(value: $time, in: 0...(2.0 * .pi))
                Slider(value: $k, in: 0...0.72)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            .padding(.bottom)
        }
        .animation(.default, value: k)
        .animation(.default, value: time)
        .ignoresSafeArea(edges: .all.subtracting(.top))
    }

    private var shader: Shader {
        let function = ShaderFunction(
            library: .default,
            name: "CircleSDF2Shader::main"
        )
        return function(.boundingRect, .float(time), .float(k))
    }

    private func reset() {
        k = 0.36
        time = .pi
    }
}

#Preview {
    CircleSDF2Screen()
}
