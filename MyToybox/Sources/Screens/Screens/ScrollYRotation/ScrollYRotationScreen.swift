import SwiftUI

struct ScrollYRotationScreen: View {
    @State private var colors: [(offset: Int, element: Color)]
        = Array(repeating: [Color].rainbow(count: 50), count: 300)
            .flatMap { $0 }
            .enumerated()
            .map { $0 }

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(colors, id: \.offset) { color in
                        RowContent(containerFrame: frame) {
                            color.element
                                .frame(height: 60)
                                .padding(8)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
        }
    }
}

private struct RowContent<Content: View>: View {
    var containerFrame: CGRect
    var content: () -> Content
    @State private var frame: CGRect = .zero

    var body: some View {
        content()
            .overlay {
                Text(String(describing: Int(ratio * 100)) + "%")
                    .fontWeight(.medium)
                    .font(.title2.monospacedDigit())
                    .foregroundStyle(.black)
            }
            .rotation3DEffect(
                .radians((2.0 * (ratio + 0.12) - 1) * .pi / 3),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                anchor: .center
            )
            .opacity(10 * (ratio + 0.1))
            .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .scrollView) }) {
                frame = $1
            }
    }

    var ratio: Double {
        guard containerFrame.size.height > 0 else {
            return 0
        }
        let x = containerFrame.size.height
        let y = frame.origin.y - containerFrame.origin.y
        return y / x
    }
}

extension [Color] {
    fileprivate static func rainbow(hue: Double = 0, count: Int) -> Self {
        (0..<count).map { i in
            var value = hue + Double(i) / Double(count)
            value -= floor(value)
            return Color(hue: value, saturation: 0.60, brightness: 1)
        }
    }
}

#Preview {
    ScrollYRotationScreen()
}
