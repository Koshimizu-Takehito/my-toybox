import MyToyboxCore
import SwiftUI

// MARK: - KeyframeAnimationScreen

@Metadata(title: .screenKeyframeAnimationTitle, description: .screenKeyframeAnimationDescription, tags: [.animation])
public struct KeyframeAnimationScreen: View {
    public init() {}

    @State private var trigger = UUID()
    /// The height available to the screen, used to scale the icon and its jump.
    @State private var height: CGFloat = 600

    public var body: some View {
        VStack {
            Spacer()
            Image(systemName: "paperplane.fill")
                .font(.system(size: min(80, 0.15 * height)))
                .foregroundStyle(.orange.gradient)
                .keyframeAnimator(
                    initialValue: AnimationValues(jumpHeight: min(250, 0.3 * height)),
                    trigger: trigger,
                    content: content,
                    keyframes: keyframes
                )
            Spacer()

            Button(action: launch) {
                Text(verbatim: "Launch")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(.blue, in: .capsule)
            }
            .padding(.bottom)
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { height in
            self.height = height
        }
    }
}

private extension KeyframeAnimationScreen {
    private func launch() {
        trigger = UUID()
    }
}

private extension KeyframeAnimationScreen {
    private struct AnimationValues {
        var scale = 1.0
        var stretchX = 1.0
        var stretchY = 1.0
        var rotation = Angle.zero
        /// The vertical offset as a fraction of `jumpHeight` (negative is up).
        var offsetY = 0.0
        var opacity = 1.0
        /// How far the icon flies up, in points. Not animated.
        var jumpHeight = 250.0
    }

    @ViewBuilder
    private nonisolated func content(content: PlaceholderContentView<some View>, values: AnimationValues) -> some View {
        content
            .scaleEffect(values.scale)
            .scaleEffect(x: values.stretchX, y: values.stretchY)
            .rotationEffect(values.rotation)
            .offset(y: values.offsetY * values.jumpHeight)
            .opacity(values.opacity)
    }

    @KeyframesBuilder<AnimationValues>
    private nonisolated func keyframes(_: AnimationValues) -> some Keyframes<AnimationValues> {
        // Scale: springy bounce.
        KeyframeTrack(\.scale) {
            SpringKeyframe(0.3, duration: 0.2, spring: .bouncy)
            SpringKeyframe(1.8, duration: 0.3, spring: .bouncy)
            SpringKeyframe(1.0, duration: 0.5, spring: .bouncy)
        }
        // Horizontal stretch: squash & stretch on landing.
        KeyframeTrack(\.stretchX) {
            LinearKeyframe(1.0, duration: 0.5)
            SpringKeyframe(1.4, duration: 0.1, spring: .snappy)
            SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
        }
        // Vertical stretch: inverse phase vs. horizontal (squash).
        KeyframeTrack(\.stretchY) {
            LinearKeyframe(1.0, duration: 0.5)
            SpringKeyframe(0.7, duration: 0.1, spring: .snappy)
            SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
        }
        // Rotation: spin during the launch arc.
        KeyframeTrack(\.rotation) {
            LinearKeyframe(.zero, duration: 0.1)
            CubicKeyframe(.degrees(360), duration: 0.6)
            CubicKeyframe(.degrees(720), duration: 0.5)
        }
        // Vertical motion: launch up, fall, and bounce.
        KeyframeTrack(\.offsetY) {
            SpringKeyframe(-1, duration: 0.4, spring: .smooth)
            SpringKeyframe(0, duration: 0.3, spring: .bouncy)
            SpringKeyframe(-0.16, duration: 0.2, spring: .smooth)
            SpringKeyframe(0, duration: 0.3, spring: .bouncy)
        }
        // Opacity: quick flash.
        KeyframeTrack(\.opacity) {
            LinearKeyframe(1.0, duration: 0.2)
            LinearKeyframe(0.4, duration: 0.1)
            LinearKeyframe(1.0, duration: 0.1)
            LinearKeyframe(0.4, duration: 0.1)
            LinearKeyframe(1.0, duration: 0.2)
        }
    }
}

#Preview {
    KeyframeAnimationScreen()
}
