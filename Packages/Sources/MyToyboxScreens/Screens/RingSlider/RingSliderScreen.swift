import SwiftUI

// MARK: - RingSliderScreen

/// A screen that demonstrates a circular slider (RingSlider) bound to a value `ratio` (0.0–1.0).
/// The background hue changes dynamically based on the ratio, and a reset button snaps the value to the nearest whole number.
@Metadata(title: .screenRingSliderTitle, description: .screenRingSliderDescription, tags: [])
struct RingSliderScreen: View {
    @State private var ratio: Double = 0

    var body: some View {
        ZStack {
            // Background color with hue rotation based on slider value
            Color(hue: 1, saturation: 0.3, brightness: 1)
                .hueRotation(.degrees(360 * ratio))
                .backgroundExtensionEffect()

            // The interactive ring slider
            RingSlider(ratio: $ratio)
                .frame(width: 300)

            // Reset button that animates `ratio` to the nearest whole value
            Button {
                reset()
            } label: {
                Text(verbatim: "Reset")
            }

            // reset() }
            .font(.title)
            .fontWeight(.bold)
        }
        .tint(.blue)
    }

    /// Animates the ratio to the nearest 0 or 1
    private func reset() {
        withAnimation {
            ratio = ratio.rounded(.toNearestOrEven)
        }
    }
}

// MARK: - RingSlider

/// A circular slider that allows users to adjust a value (0.0–1.0) by dragging around a ring.
struct RingSlider: View, Animatable {
    @Binding private var ratio: Double

    /// Used by SwiftUI animation system to interpolate `ratio`
    var animatableData: Double

    init(ratio: Binding<Double>) {
        self._ratio = ratio
        self.animatableData = ratio.wrappedValue
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let ringRadius = min(size.width, size.height) / 2

            ZStack {
                // --- Ring background ---
                let dotSize = ringRadius / 3
                let lineWidth = 0.5 * dotSize

                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .foregroundStyle(.tint)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)

                // --- Movable dot indicator ---
                let effectiveRadius = ringRadius - lineWidth / 2
                let angle = 2 * .pi * animatableData - .pi / 2

                Circle()
                    .frame(width: dotSize, height: dotSize)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .offset(
                        x: effectiveRadius * cos(angle),
                        y: effectiveRadius * sin(angle)
                    )
            }
            .gesture(
                DragGesture().onChanged { value in
                    // Convert drag location into polar angle
                    var location = value.location
                    location.x -= ringRadius
                    location.y -= ringRadius
                    location.y *= -1 // Flip Y-axis to match polar coordinate system

                    // Compute angle ratio between 0.0 and 1.0
                    let angleRatio = atan2(location.x, location.y) / (2 * .pi)
                    ratio = (angleRatio + 1).remainder(dividingBy: 1)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    RingSliderScreen()
}
