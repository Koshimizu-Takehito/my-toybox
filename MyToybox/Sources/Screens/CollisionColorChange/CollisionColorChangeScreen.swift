import SwiftUI

/// A screen that demonstrates a simple collision-based color-changing animation.
///
/// An image moves within the view bounds, bouncing off the edges. Each collision
/// changes the item's background color based on a hue rotation.
struct CollisionColorChangeScreen: View {
    var body: some View {
        CollisionAnimationView(speed: .init(dx: 100, dy: 140))
    }
}

/// A view that animates an item moving within the container bounds.
/// The item bounces off edges, and each collision triggers a color change.
private struct CollisionAnimationView: View {
    /// The movement speed vector (points per second).
    var speed: CGVector

    /// The time when the animation started.
    private let startTime: Date = .now

    /// The number of collisions that have occurred.
    @State private var collision: Int = 0

    /// The size of the item being animated.
    @State private var itemSize: CGSize = .zero

    /// The current velocity vector (difference in position per frame).
    @State private var velocity: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                let elapsed = context.date.timeIntervalSince(startTime)
                let offset = offset(container: geometry.size, movement: elapsed * speed)

                ItemView(size: $itemSize)
                    .background(itemColor())
                    .offset(x: -itemSize.width / 2, y: -itemSize.height / 2)
                    .offset(x: offset.x, y: offset.y)
                    .onChange(of: offset) { old, new in
                        // Track velocity by measuring frame-to-frame change
                        velocity = old - new
                    }
                    .onChange(of: velocity) { old, new in
                        // Detect directional reversal (collision)
                        if old.x * new.x < 0 || old.y * new.y < 0 {
                            collision += 1
                        }
                    }
            }
        }
        .padding(.horizontal, itemSize.width / 2)
        .padding(.vertical, itemSize.height / 2)
        .background(Color(white: 28 / 255))
        .clipped()
        .padding()
    }

    /// Returns the current color of the item based on the number of collisions.
    func itemColor() -> Color {
        let hue = Double((collision * 150) % 360) / 360
        return Color(hue: hue, saturation: 0.7, brightness: 1)
    }

    /// Calculates the new position offset for the item within a given container size.
    /// The item reverses direction when hitting a boundary (simulating a bounce).
    func offset(container size: CGSize, movement: CGVector) -> CGPoint {
        func calc(_ axis: KeyPath<CGVector, CGFloat>, _ dim: KeyPath<CGSize, CGFloat>) -> CGFloat {
            let travel = movement[keyPath: axis]
            let range = size[keyPath: dim]
            let quotient = travel / range
            let remainder = travel.truncatingRemainder(dividingBy: range)
            return Int(floor(quotient)).isMultiple(of: 2)
                ? remainder
                : range - remainder
        }

        return CGPoint(
            x: calc(\.dx, \.width),
            y: calc(\.dy, \.height)
        )
    }
}

/// A view representing the animated item (a PlayStation logo).
/// Its size is reported using a geometry proxy.
private struct ItemView: View {
    @Binding var size: CGSize

    var body: some View {
        Image(systemName: "playstation.logo")
            .resizable()
            .scaledToFit()
            .font(.largeTitle)
            .imageScale(.large)
            .padding()
            .frame(width: 120, height: 100)
            .onGeometryChange(for: CGSize.self, of: \.size) { _, newSize in
                self.size = newSize
            }
    }
}

// Vector arithmetic helpers

private extension CGPoint {
    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

private extension CGVector {
    static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        .init(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
    }
}

#Preview {
    CollisionColorChangeScreen()
}
