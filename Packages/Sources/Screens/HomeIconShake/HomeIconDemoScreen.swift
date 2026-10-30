import MyToyboxCore
import SwiftUI

// MARK: - HomeIconDemoScreen

/// Shows a 4×4 grid of SF Symbols that can enter "jiggle mode"
/// like the iOS Home‑Screen icons.
///
@Metadata(title: .screenHomeIconDemoTitle, description: .screenHomeIconDemoDescription, tags: [.animation])
public struct HomeIconDemoScreen: View {
    public init() {}

    public var body: some View {
        HomeIconView()
    }
}

// MARK: - HomeIconView

/// A 4 × 4 grid of tappable icons whose appearance mimics
/// Home‑Screen app icons.
/// Tapping **Edit / Done** in the toolbar toggles jiggle mode.
struct HomeIconView: View {
    /// `true` while the user is in edit (jiggle) mode.
    @State private var isEditingMode = true
    @State private var model = HomeIconModel(numberOfColumn: 4)

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(model.items, id: \.self) { items in
                GridRow {
                    ForEach(items) { item in
                        Image(systemName: item.symbol)
                            .modifier(IconModifier(style: item.color))
                            .modifier(JiggleModifier(isEnabled: isEditingMode))
                    }
                }
            }
        }
        .padding()
        .toolbar {
            Button {
                isEditingMode.toggle()
            } label: {
                Text(verbatim: isEditingMode ? "Done" : "Edit")
            }
            .fontWeight(isEditingMode ? .regular : .semibold)
        }
    }
}

// MARK: - IconModifier

/// Renders the content as a square app icon that scales with its grid cell,
/// so the 4 × 4 grid fits narrow detail columns as well as wide screens.
struct IconModifier<S: ShapeStyle>: ViewModifier {
    var style: S

    func body(content: Content) -> some View {
        Color.clear
            .frame(maxWidth: 96)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    let side = proxy.size.width
                    let shape = RoundedRectangle(cornerRadius: side * 0.22, style: .continuous)
                    content
                        .font(.system(size: side * 0.45))
                        .foregroundStyle(.white)
                        .frame(width: side, height: side)
                        .background(style, in: shape)
                        .overlay(shape.strokeBorder(.white.secondary, lineWidth: 1))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(10)
    }
}

// MARK: - JiggleModifier

/// Adds a subtle, indefinite “jiggle” animation to its content
/// while `isEnabled` is `true`. The effect closely approximates
/// the one Apple uses in Home‑Screen edit mode.
struct JiggleModifier: ViewModifier {
    /// Toggles the jiggle animation on and off.
    var isEnabled: Bool

    /// Normalized phase of the animation (`0…1`).
    @State private var animationPhase: Double = 0

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func body(content: Content) -> some View {
        // Each icon gets a slightly different offset to avoid perfect sync.
        let baseRandomOffset: Double = isEnabled ? .random(in: -1 ..< 1) : 0
        JiggleView(
            phase: animationPhase,
            baseRandomOffset: baseRandomOffset,
            content: content
        )
        .id(isEnabled) // Reset phase whenever the mode toggles.
        .onChange(of: isEnabled, initial: true) { _, editing in
            animationPhase = 0
            if editing {
                withAnimation(.linear(duration: 0.3).repeatForever().delay(.random(in: 0 ..< 0.2))) {
                    animationPhase = 1
                }
            } else {
                animationPhase = 0.25 // Quick settle‑down
            }
        }
    }
}

// MARK: - JiggleView

/// Applies a wobbling rotation and position offset based on `phase`.
private struct JiggleView<Content: View>: View, Animatable {
    nonisolated var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    /// Normalized animation phase (`0…1`), automatically interpolated.
    nonisolated var phase: Double

    /// Random variance so that icons do not move in perfect unison.
    var baseRandomOffset: Double = .random(in: -1 ..< 1)

    /// The underlying content to animate.
    var content: Content

    var body: some View {
        content
            .rotationEffect(rotationAngle())
            .offset(positionOffset())
    }

    /// Returns a small oscillating rotation angle.
    private func rotationAngle() -> Angle {
        Angle.radians(
            (cos(phase * 2 * .pi) + baseRandomOffset) * Angle.degrees(2).radians
        )
    }

    /// Produces a subtle *x/y* offset for extra “life”.
    private func positionOffset() -> CGSize {
        let amplitude = CGSize(width: 0.5, height: 0.25)
        let x = cos(phase * 2 * .pi + baseRandomOffset * .pi) * amplitude.width
        let y = sin(phase * 4 * .pi + baseRandomOffset * .pi) * amplitude.height
        return CGSize(width: x, height: y)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeIconDemoScreen()
    }
}
