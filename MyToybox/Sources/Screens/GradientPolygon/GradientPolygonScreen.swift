import SwiftUI

// MARK: - GradientPolygonScreen

/// A screen that displays a customizable polygon with a gradient fill.
///
/// Users can adjust the number of vertices (3–9) and the "roundness" of the polygon
/// using interactive controls. The polygon morphs smoothly between sharp and rounded corners.
struct GradientPolygonScreen: View {
    /// The number of vertices of the polygon (e.g., 3 for triangle, 6 for hexagon).
    @State var vertex = 6

    /// The smoothness of the polygon's corners, ranging from 0 (sharp) to 1 (fully rounded).
    @State var roundness: Double = 0.5

    var body: some View {
        VStack {
            // Display the gradient-filled polygon.
            PolygonShape(vertex: vertex, roundness: roundness)
                .fill(gradient)
                .scaledToFit()
                .id(vertex) // Forces redraw when vertex count changes

            VStack {
                // Vertex count adjustment.
                Stepper("Vertex", value: $vertex, in: 3...9)

                // Roundness control with reset button.
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

    /// The linear gradient used to fill the polygon.
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

// MARK: - PolygonShape

/// A custom shape representing a polygon with rounded corners.
///
/// The number of vertices (`vertex`) determines the polygon's sides.
/// The `roundness` value defines how rounded each corner is, allowing smooth morphing.
private struct PolygonShape: Shape {
    var vertex = 6
    var roundness: Double = 0.5

    /// Enables implicit animation of the roundness value.
    var animatableData: Double {
        get { roundness }
        set { roundness = min(max(newValue, 0), 1) }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let theta = 2 * Double.pi / Double(vertex)

        // Base polygon points (with one extra to complete the cycle).
        let basePoints: [CGPoint] = (0...(vertex + 1)).map { index in
            CGPoint(radius: radius, theta: Double(index) * theta)
        }

        // Ratio determines how much the corners are rounded.
        let ratio = min(max(-abs(roundness / 2.0 - 0.5) + 0.5, 0), 1)

        // Control points for Bezier curves.
        let controlA = zip(basePoints, basePoints.dropFirst()).map {
            ratio * $0 + (1 - ratio) * $1
        }
        let controlB = zip(basePoints, basePoints.dropFirst()).map {
            (1 - ratio) * $0 + ratio * $1
        }

        // Construct the path using quadratic curves.
        let path = Path { path in
            path.move(to: center + controlA[vertex - 1])
            for index in 0..<vertex {
                let p0 = center + controlA[(index + vertex - 1) % vertex]
                let p2 = center + controlB[index]
                let p1 = center + basePoints[index]

                // Two control points for a cubic Bezier curve
                let c1 = p0 + (2 / 3) * (p1 - p0)
                let c2 = p2 + (2 / 3) * (p1 - p2)

                path.addLine(to: p0)
                path.addCurve(to: p2, control1: c1, control2: c2)
            }
            path.closeSubpath()
        }

        // Rotate the polygon to center the first vertex at the top.
        let rotation = (theta / 2.0) + (vertex.isMultiple(of: 2) ? 0 : .pi / 2.0)
        return path.rotation(.radians(rotation)).path(in: rect)
    }
}

// MARK: - CGPoint

extension CGPoint {
    /// Creates a point on a circle with the given radius and angle (in radians).
    fileprivate init(radius: CGFloat, theta radians: Double) {
        self.init(x: radius * cos(radians), y: radius * sin(radians))
    }

    fileprivate static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    fileprivate static func - (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    fileprivate static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        .init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    fileprivate static func / (_ lhs: Self, _ rhs: CGFloat) -> Self {
        .init(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

#Preview {
    GradientPolygonScreen()
}
