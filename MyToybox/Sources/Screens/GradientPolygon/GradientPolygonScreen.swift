import SwiftUI

struct GradientPolygonScreen: View {
    @State var vertex = 6
    @State var roundness: Double = 0.5

    var body: some View {
        VStack {
            Polygon(vertex: vertex, roundness: roundness)
                .fill(gradient)
                .scaledToFit()
                .id(vertex)
            VStack {
                Stepper("Vertex", value: $vertex, in: 3...9)
                HStack {
                    Button("Reset") {
                        roundness = 0.5
                    }
                    Slider(value: $roundness, in: 0...1)
                }
            }
        }
        .padding()
        .animation(.default, value: roundness)
        .animation(.default, value: vertex)
    }

    var gradient: some ShapeStyle {
        .linearGradient(
            colors: [
                Color(red: 0xEF / 0xFF, green: 0x78 / 0xFF, blue: 0xDD / 0xFF),
                Color(red: 0xEF / 0xFF, green: 0xAC / 0xFF, blue: 0x78 / 0xFF),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 0.6)
        )
    }
}

private struct Polygon: Shape {
    var vertex = 6
    var roundness: Double = 0.5

    var animatableData: Double {
        get { roundness }
        set { roundness = min(max(newValue, 0), 1) }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let theta = 2 * Double.pi / Double(vertex)
        let pp: [CGPoint] = (0...(vertex + 1)).map { index in
            CGPoint(radius: radius, theta: Double(index) * theta)
        }

        let ratio = min(max(-abs(roundness / 2.0 - 0.5) + 0.5, 0), 1)
        let qq = zip(pp, pp.dropFirst()).map {
            ratio * $0 + (1 - ratio) * $1
        }
        let rr = zip(pp, pp.dropFirst()).map {
            (1 - ratio) * $0 + ratio * $1
        }
        let path = Path { path in
            path.move(to: center + qq[vertex - 1])
            for index in 0..<vertex {
                let p0 = center + qq[(index + vertex - 1) % vertex]
                let p2 = center + rr[index]
                let p1 = center + pp[index]
                let c1 = p0 + 2 / 3 * (p1 - p0)
                let c2 = p2 + 2 / 3 * (p1 - p2)
                path.addLine(to: p0)
                path.addCurve(to: p2, control1: c1, control2: c2)
            }
            path.closeSubpath()
        }

        let rotation = (theta / 2.0) + (vertex.isMultiple(of: 2) ? 0 : .pi / 2.0)
        return
            path
            .rotation(.radians(rotation))
            .path(in: rect)
    }
}

extension CGPoint {
    fileprivate init(radius: CGFloat, theta radians: Double) {
        self.init(x: radius * cos(radians), y: radius * sin(radians))
    }

    fileprivate static func + (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    fileprivate static func - (_ lhs: Self, _ rhs: Self) -> Self {
        self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    fileprivate static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        self.init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    fileprivate static func / (_ lhs: Self, _ rhs: CGFloat) -> Self {
        self.init(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

#Preview {
    GradientPolygonScreen()
}
