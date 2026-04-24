import SwiftUI

// MARK: - OrbitingDotsLoaderDemoScreen

/// Demonstrates `OrbitingDotsLoadingView` and lets you preview it at any
/// built-in `ControlSize`.
///
/// The loader is centered, while the bottom `ControlSizePicker` writes
/// to `controlSize`, automatically propagating the value down the view
/// hierarchy through `.controlSize(_:)`.
@Metadata(title: .screenLoadingOrbitingDotsTitle, description: .screenLoadingOrbitingDotsDescription, tags: [.animation])
struct OrbitingDotsLoaderDemoScreen: View {
    @State private var controlSize: ControlSize = .regular

    // MARK: Body

    var body: some View {
        VStack {
            Spacer()
            OrbitingDotsLoadingView()
                .controlSize(controlSize)
            Spacer()
            ControlSizePickerView($controlSize)
        }
    }
}

// MARK: - ControlSizePickerView

/// A palette-style picker that exposes every `ControlSize` case.
///
/// - Parameter selection: Two-way binding for the chosen size.
private struct ControlSizePickerView: View {
    @Binding var selection: ControlSize

    init(_ selection: Binding<ControlSize>) {
        _selection = selection
    }

    var body: some View {
        Picker(String(describing: ControlSize.self), selection: $selection) {
            ForEach(ControlSize.allCases, id: \.self) { size in
                Text(size.formatted())
            }
        }
        .pickerStyle(.palette)
        .padding()
    }
}

// MARK: - OrbitingDotsLoadingView

/// A colorful loading indicator composed of eight dots orbiting the same
/// circular path.
/// Honors **“Reduce Motion”** by pausing rotation when the accessibility
/// setting is enabled and automatically scales with the surrounding
/// `ControlSize`.
struct OrbitingDotsLoadingView: View {
    /// Current control size supplied by ancestors.
    @Environment(\.controlSize) private var controlSize: ControlSize
    /// Indicates whether the user requested reduced motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    var body: some View {
        let boxWidth: CGFloat = 150

        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            // 3 rad/s, clamped to one full revolution (0 … 2π).
            let sharedRotationAngle = reduceMotion ? 0 : 3 * t.truncatingRemainder(dividingBy: 2 * .pi)

            OrbitingDotsLayerView(
                sharedRotationAngle: sharedRotationAngle,
                orbitRadius: boxWidth / 6
            )
        }
        .frame(width: boxWidth, height: boxWidth)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: boxWidth / 5))
        .scaleEffect(scaleFactor(for: controlSize))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: controlSize)
    }

    /// Maps each `ControlSize` to a visually pleasing scale factor.
    private func scaleFactor(for size: ControlSize) -> CGFloat {
        switch size {
        case .mini: 0.25
        case .small: 0.50
        case .regular: 1.00
        case .large: 1.50
        case .extraLarge: 2.00
        @unknown default: 1.00
        }
    }
}

// MARK: - OrbitingDotsLayerView

/// Renders eight equally spaced dots, each offset by a unique phase so
/// they animate in a perfect ring.
struct OrbitingDotsLayerView: View {
    /// Shared rotation angle applied to every dot (0 … 2π).
    let sharedRotationAngle: Double
    /// Radius of the circular path.
    let orbitRadius: Double

    var body: some View {
        ZStack {
            ForEach(0 ..< 8) { index in
                let phaseOffset = 2 * .pi * Double(index) / 8
                let baseAngle = sharedRotationAngle + phaseOffset
                OrbitingDot(orbitRadius: orbitRadius, baseAngle: baseAngle, phaseOffset: phaseOffset)
            }
        }
    }
}

// MARK: - OrbitingDot

/// A single dot that orbits `orbitRadius` away from center and animates
/// both its scale and color according to `baseAngle`.
private struct OrbitingDot: View {
    /// Orbit radius.
    let orbitRadius: Double
    /// Runtime angle (radians) used for position & scale.
    let baseAngle: Double
    /// Constant phase offset set at initialization.
    let phaseOffset: Double

    var body: some View {
        // Scale pulsates between 0.5 and 1.5.
        let scale = 0.5 + abs((baseAngle - .pi).remainder(dividingBy: 2 * .pi)) / (2 * .pi)
        let dotColor = color(for: scale)

        Circle()
            .frame(width: orbitRadius / 2)
            .scaleEffect(scale)
            .offset(
                x: orbitRadius * (cos(baseAngle + phaseOffset) + cos(phaseOffset)),
                y: orbitRadius * (sin(baseAngle + phaseOffset) + sin(phaseOffset))
            )
            .foregroundStyle(dotColor)
            .shadow(color: dotColor.opacity(0.5), radius: 10, y: 15 * scale)
    }

    /// Produces a bright rainbow `Color` from a 0 … 1 scale value.
    private func color(for scale: Double) -> Color {
        Color(hue: scale, saturation: 1, brightness: 1)
    }
}

// MARK: - ControlSize convenience

private extension ControlSize {
    /// Human-readable label used by `ControlSizePicker`.
    func formatted() -> String {
        switch self {
        case .extraLarge:
            "xLarge"

        default:
            String(describing: self).capitalized
        }
    }
}

// MARK: - Preview

#Preview {
    OrbitingDotsLoaderDemoScreen()
}
