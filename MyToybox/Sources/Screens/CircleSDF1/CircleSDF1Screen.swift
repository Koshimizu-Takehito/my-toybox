import SwiftUI

struct CircleSDF1Screen: View {
    private let start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            Rectangle().colorEffect(shader(
                seconds: context.date.timeIntervalSince(start)
            ))
        }
        .ignoresSafeArea(edges: .all.subtracting(.top))
    }

    private func shader(seconds: TimeInterval) -> Shader {
        let function = ShaderFunction(library: .default, name: "CircleSDF1Shader::main")
        return function(.boundingRect, .float(seconds))
    }
}

#Preview {
    CircleSDF1Screen()
}
