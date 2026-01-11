import SwiftUI

// MARK: - SolarSystem1Screen

/// A SwiftUI view that simulates a simplified solar system animation.
///
/// The central "sun" remains stationary while six "planets" orbit around it at different speeds,
/// representing varying orbital periods.
///
/// The animation restarts when the screen is tapped.
struct SolarSystem1Screen: View {
    /// The time when the animation started.
    @State private var start: Date = .now

    var body: some View {
        GeometryReader { geometry in
            // Determine the base radius for orbit calculation
            let radius = geometry.size.width * 5 / 100
            // A helper closure to calculate orbital radius for each planet based on index
            let offset: (_ index: Int) -> CGFloat = { index in
                radius / 2 + (4 + 3 * CGFloat(index)) * radius / 2
            }
            TimelineView(.animation) { context in
                let progress = context.date.timeIntervalSince(start) / 10
                ZStack {
                    // Central sun
                    Sphere(color: .red.mix(with: .orange, by: 0.2))
                        .frame(width: 1.5 * radius)
                        .overlay {
                            Text("S")
                                .fontWeight(.bold)
                        }
                    // Orbital paths
                    ForEach(0 ..< 6) { index in
                        Circle()
                            .stroke(lineWidth: 1)
                            .frame(width: 2 * offset(index))
                    }
                    // Orbiting planets with different speeds
                    Group {
                        // Mercury
                        Sphere(color: .blue, offset: offset(0), progress: progress / 0.24)
                        // Venus
                        Sphere(color: .yellow, offset: offset(1), progress: progress / 0.62)
                        // Earth
                        Sphere(color: .green, offset: offset(2), progress: progress)
                        // Mars
                        Sphere(color: .red, offset: offset(3), progress: progress / 1.88)
                        // Jupiter
                        Sphere(color: .brown, offset: offset(4), progress: progress / 11.86)
                        // Saturn
                        Sphere(color: .gray, offset: offset(5), progress: progress / 29.46)
                    }
                    .frame(width: radius)
                }
            }
        }
        .padding()
        .padding()
        .padding()
        .scaledToFit()
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 28 / 255))
        .onTapGesture {
            start = .now
        }
    }
}

// MARK: - Sphere

/// A view that draws a circular object (planet) and animates its position around a center point.
///
/// - Parameters:
///   - color: The fill color of the sphere.
///   - offset: The orbital radius from the center.
///   - progress: A normalized value (0.0–1.0) representing the current rotation progress.
private struct Sphere: View {
    var color: Color
    var offset: CGFloat = .zero
    var progress: CGFloat = 1.0

    var body: some View {
        let theta = -2 * .pi * progress
        color.clipShape(.circle)
            .offset(x: offset * cos(theta), y: offset * sin(theta))
    }
}

// MARK: - Preview

#Preview {
    SolarSystem1Screen()
}
