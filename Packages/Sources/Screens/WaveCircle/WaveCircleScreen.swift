import MyToyboxCore
import SwiftUI

// MARK: - WaveCircleScreen

/// A screen that visually represents a percentage using a circular wave animation.
/// The user can adjust the percentage using a slider.
@Metadata(title: .screenWaveCircleTitle, description: .screenWaveCircleDescription, tags: [.animation])
public struct WaveCircleScreen: View {
    public init() {}

    @State private var percent = 0.50

    public var body: some View {
        VStack {
            // A view that renders the animated wave within a circle.
            WaveCircleAnimationView(percent: percent)
                .font(.system(size: 60).monospacedDigit())
                .fontWeight(.bold)
                .fontDesign(.rounded)

            // A slider to change the percentage value interactively.
            Slider(value: $percent.animation(), in: 0 ... 1, step: 0.01)
        }
        .foregroundStyle(.tint)
        .tint(.blue)
        .padding()
    }
}

// MARK: - WaveCircleAnimationView

/// A circular view that displays an animated water wave representing the given percentage.
/// Two overlapping waves are rendered to create a layered effect.
struct WaveCircleAnimationView: View {
    let percent: Double
    @State private var transition: ContentTransition = .identity

    var body: some View {
        TimelineView(.animation) { context in
            let offset = offset(context.date)
            WaveCircleContentView(percent: percent, offset: offset)
        }
        .scaledToFit()
        .clipShape(.circle)
        .contentTransition(transition)
        .onChange(of: percent) { old, new in
            transition = .numericText(countsDown: old > new)
        }
    }

    /// Calculates a wave phase offset based on time to animate the wave horizontally.
    private func offset(_ date: Date) -> Angle {
        var value = date.timeIntervalSinceReferenceDate
        value.formTruncatingRemainder(dividingBy: 2 * .pi)
        value *= 2
        return .radians(value)
    }
}

// MARK: - WaveCircleContentView

struct WaveCircleContentView: View {
    var percent: Double
    var offset: Angle
    var lineWidth: Double = 8

    var body: some View {
        ZStack {
            // Circular outline
            Circle()
                .stroke(lineWidth: lineWidth)

            // First wave layer
            WaveShape(percent: percent, offset: offset)
                .opacity(0.4)

            // Second wave layer with phase and position offset
            WaveShape(percent: percent, offset: offset + .degrees(60), xOffset: 0.7)
                .opacity(0.4)

            // Display percentage as text
            Text(percent, format: .percent)
        }
    }
}

// MARK: - WaveShape

/// A shape that renders a horizontal sine wave clipped to a container,
/// used to simulate water movement within a progress indicator.
private struct WaveShape: Shape {
    /// The progress (height of the wave)
    var percent: Double
    /// The horizontal wave phase offset (for animation)
    var offset: Angle
    /// Additional horizontal offset (for second wave layer)
    var xOffset: Double = 0

    var animatableData: AnimatablePair<AnimatablePair<Double, Double>, Double> {
        get {
            .init(.init(percent, offset.radians), xOffset)
        }
        set {
            percent = newValue.first.first
            offset.radians = newValue.first.second
            xOffset = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // Top Y of the wave
            let midHeight = height * (1 - percent)
            // Amplitude of the wave
            let waveHeight = height * 0.06

            // Start from bottom-left corner
            path.move(to: CGPoint(x: 0, y: rect.maxY))

            // Draw the wave using a sine function
            for x in stride(from: 0, to: width, by: 2) {
                let phase = (x / width + xOffset) * 2 * .pi + offset.radians
                let y = midHeight + waveHeight * sin(phase)
                path.addLine(to: CGPoint(x: x, y: y))
            }

            // Draw to bottom-right corner and close
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview {
    WaveCircleScreen()
}
