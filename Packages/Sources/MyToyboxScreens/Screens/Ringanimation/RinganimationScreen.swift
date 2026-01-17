import SwiftUI

// MARK: - RinganimationScreen

/// A screen that displays three animated concentric progress rings.
/// Each ring rotates at a different speed and animates continuously using `TimelineView`.
@Metadata(title: "Ringanimation", description: "Ring Animation", tags: [.animation])
struct RinganimationScreen: View {
    let startTime: Date = .now

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            TimelineView(.animation) { context in
                // Calculate elapsed time and normalize progress to [0, 1)
                let time = context.date.timeIntervalSince(startTime)
                let progress = (time / 4).truncatingRemainder(dividingBy: 1)

                RotatingProgressRingsView(progress: progress)
                    .padding(0.3 * width)
                    .frame(width: width)
            }
        }
        .scaledToFit()
    }
}

// MARK: - RotatingProgressRingsView

/// A view that renders three concentric animated rings.
/// Each ring rotates at a different speed and uses gradient coloring to indicate progress.
private struct RotatingProgressRingsView: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let lineWidth = geometry.size.width / 10
            let ringPadding = 1.2 * lineWidth

            ZStack {
                RotatingProgressRingSegment(value: progress, speed: 4, lineWidth: lineWidth)
                    .foregroundStyle(gradient(.yellow, .orange))
                    .padding(2 * ringPadding)

                RotatingProgressRingSegment(value: progress, speed: 3, lineWidth: lineWidth)
                    .foregroundStyle(gradient(.mint, .green))
                    .padding(ringPadding)

                RotatingProgressRingSegment(value: progress, speed: 2, lineWidth: lineWidth)
                    .foregroundStyle(gradient(.cyan, .blue))
            }
        }
        .scaledToFit()
    }

    /// Creates a vertical gradient from the provided colors.
    private func gradient(_ colors: Color...) -> LinearGradient {
        LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - RotatingProgressRingSegment

/// A single animated progress ring segment.
/// The ring is visually represented by a trimmed circle segment that rotates based on its speed and progress value.
private struct RotatingProgressRingSegment {
    var value = 0.0 // Progress value in the range [0, 1]
    var speed = 1.0 // Speed multiplier for rotation
    var lineWidth = 10.0 // Stroke thickness of the ring
}

// MARK: View

extension RotatingProgressRingSegment: View {
    var body: some View {
        let trimFraction = trimFraction // Shadowed to clarify meaning

        ZStack {
            // Background circle track
            Circle()
                .stroke(lineWidth: lineWidth * 0.8)
                .foregroundStyle(.gray.opacity(0.3))

            // Foreground progress arc
            Circle()
                .trim(from: trimFraction.from, to: trimFraction.to)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90.0 + (360.0 * speed * value)))
        }
    }

    /// Calculates how much of the circle to trim based on the progress value.
    /// First half of the animation increases the arc, second half decreases it.
    private var trimFraction: (from: Double, to: Double) {
        if value <= 0.5 {
            (0, value * 2)
        } else {
            ((value - 0.5) * 2, 1)
        }
    }
}

// MARK: Animatable

extension RotatingProgressRingSegment: Animatable {
    /// Enables smooth animation by treating `value` as animatable data.
    var animatableData: Double {
        get { max(min(value, 1), 0) }
        set { value = max(min(newValue, 1), 0) }
    }
}

#Preview {
    RinganimationScreen()
}
