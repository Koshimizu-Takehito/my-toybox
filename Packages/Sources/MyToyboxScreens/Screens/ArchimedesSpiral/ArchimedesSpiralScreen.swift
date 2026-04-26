import SwiftUI

// MARK: - ArchimedesSpiralScreen

/// A SwiftUI view that draws a dynamic Archimedean spiral animation using `Canvas`.
///
/// The spiral continuously rotates and changes color over time.
/// Tapping the screen resets the animation's start time.
/// The animation is driven by `TimelineView`, which updates regularly with `.animation` schedule.
@Metadata(title: .screenArchimedesSpiralTitle, description: .screenArchimedesSpiralDescription, tags: [.animation])
struct ArchimedesSpiralScreen: View {
    /// The start time of the animation. Used to calculate elapsed time.
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { context in
            // Calculate the elapsed time in seconds, normalized over 120 seconds.
            let time = context.date.timeIntervalSince(start) / 120
            ArchimedesSpiralContent(time: time)
        }
        .background(.black)
        .onTapGesture {
            // Reset the animation by setting a new start time.
            start = .now
        }
        .backgroundExtensionEffect()
    }
}

// MARK: - ArchimedesSpiralContent

struct ArchimedesSpiralContent: View {
    var time: Double

    var body: some View {
        // Rotation factor oscillates between 0.8 and 1.0 using a cosine wave.
        let rotation = 0.8 + 0.2 * abs((cos(.pi * time) + 1.0) / 2.0)

        Canvas { context, size in
            let radius = 2.0

            // Define the center point of the canvas.
            let center = CGPoint(x: size.width / 2 - radius, y: size.height / 2 - radius)
            let pointSize = CGSize(width: 2 * radius, height: 2 * radius)

            for i in 0 ..< 3000 {
                let j = rotation * Double(i)

                // Calculate the point on the spiral, scaled down by half.
                let p = CGPoint.spiral(at: .radians(j)) / 2

                // Draw a small circle at the computed position.
                let path = Circle().path(in: CGRect(origin: center + p, size: pointSize))

                // Compute hue value to generate a colorful spiral effect.
                let hue = j.truncatingRemainder(dividingBy: 255) / 255
                context.fill(path, with: .color(Color(hue: hue)))
            }
        }
    }
}

private extension CGPoint {
    /// Computes a point on an Archimedean spiral given an angle in radians.
    static func spiral(at angle: Angle) -> Self {
        let r = angle.radians
        return CGPoint(x: r * cos(r), y: r * sin(r))
    }

    /// Adds two `CGPoint` values.
    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtracts one `CGPoint` from another.
    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Multiplies a `CGPoint` by a scalar.
    static func * (_ lhs: Double, _ rhs: Self) -> Self {
        .init(x: lhs * rhs.x, y: lhs * rhs.y)
    }

    /// Divides a `CGPoint` by a scalar.
    static func / (_ lhs: Self, _ rhs: Double) -> Self {
        .init(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

private extension Color {
    /// Initializes a color with a given hue, fixed saturation and brightness.
    init(hue: Double) {
        self.init(hue: hue, saturation: 0.6, brightness: 1)
    }
}

#Preview {
    ArchimedesSpiralScreen()
}
