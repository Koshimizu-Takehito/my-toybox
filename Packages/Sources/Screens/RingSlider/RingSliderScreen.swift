import MyToyboxCore
import SwiftUI

// MARK: - RingSliderScreen

@MainActor
@Metadata(title: .screenRingSliderTitle, description: .screenRingSliderDescription, tags: [])
public struct RingSliderScreen: View {
    @State private var ratio: Double = 0

    public init() {}

    public var body: some View {
        ZStack {
            Color(hue: 1, saturation: 0.3, brightness: 1)
                .hueRotation(.degrees(360 * ratio))
                .backgroundExtensionEffect()
            RingSlider(ratio: $ratio)
                .frame(width: 300)
            Button {
                reset()
            } label: {
                Text(verbatim: "Reset")
            }
            .font(.title)
            .fontWeight(.bold)
        }
        .tint(.blue)
    }

    private func reset() {
        withAnimation {
            ratio = ratio.rounded(.toNearestOrEven)
        }
    }
}

// MARK: - RingSlider

struct RingSlider: View, Animatable {
    @Binding private var ratio: Double
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
                let dotSize = ringRadius / 3
                let lineWidth = 0.5 * dotSize

                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .foregroundStyle(.tint)
                    .frame(width: ringRadius * 2, height: ringRadius * 2)

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
                    var location = value.location
                    location.x -= ringRadius
                    location.y -= ringRadius
                    location.y *= -1
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
