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
            GeometryReader { geometry in
                // The visible area, in the coordinates of the full-bleed rectangle below,
                // so a floating sidebar or the home indicator does not shift the circles.
                let visibleRect = CGRect(
                    origin: CGPoint(x: geometry.safeAreaInsets.leading, y: 0),
                    size: geometry.size
                )
                Rectangle()
                    .colorEffect(.circleSDF2(time: time, k: k, in: visibleRect))
                    .ignoresSafeArea(edges: .all.subtracting(.top))
            }

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
    /// - Parameter rect: The area the circles are laid out in, or `nil` for the view's bounds.
    static func circleSDF2(time: TimeInterval, k: Double, in rect: CGRect? = nil) -> Shader {
        let function = ShaderFunction(library: .screenModule, name: "CircleSDF2Shader::main")
        let box: Shader.Argument = rect.map { .float4($0.minX, $0.minY, $0.width, $0.height) } ?? .boundingRect
        return function(box, .float(time), .float(k))
    }
}

#Preview {
    CircleSDF2Screen()
}
