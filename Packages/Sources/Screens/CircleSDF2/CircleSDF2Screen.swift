import MyToyboxCore
import SwiftUI

// MARK: - CircleSDF2Screen

@MainActor
@Metadata(title: .screenCircleSDF2Title, description: .screenCircleSDF2Description, tags: [.animation, .metal])
public struct CircleSDF2Screen: View {
    @State private var k: Double = 0.36
    @State private var time: Double = .pi

    public init() {}

    public var body: some View {
        ZStack {
            // Only the shader extends under the bars; the controls stay inside the safe area.
            Rectangle()
                .colorEffect(.circleSDF2(time: time, k: k))
                .backgroundExtensionEffect()

            VStack {
                Button(action: reset) {
                    Text(verbatim: "Reset")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Slider(value: $time, in: 0 ... (2.0 * .pi))
                Slider(value: $k, in: 0 ... 0.72)
            }
            .frame(maxWidth: 400)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            .tint(.blue)
        }
        .animation(.default, value: k)
        .animation(.default, value: time)
    }

    private func reset() {
        k = 0.36
        time = .pi
    }
}

extension Shader {
    static func circleSDF2(time: TimeInterval, k: Double) -> Shader {
        let function = ShaderFunction(library: .screenModule, name: "CircleSDF2Shader::main")
        return function(.boundingRect, .float(time), .float(k))
    }
}

#Preview {
    CircleSDF2Screen()
}
