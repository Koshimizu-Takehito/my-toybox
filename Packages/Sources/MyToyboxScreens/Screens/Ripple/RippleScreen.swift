import SwiftUI

// MARK: - RippleScreen

/// A screen that plays a water-surface ripple effect centered on the tap location.
///
/// ## Attribution
/// The ripple distortion technique is **inspired by** Apple’s WWDC 2024 session
/// *Create Custom Visual Effects with SwiftUI* (session [10151](https://developer.apple.com/videos/play/wwdc2024/10151/)).
/// WWDC videos, transcripts, and related Apple Developer materials are **© Apple Inc.**
/// All rights reserved by their respective owners.
///
/// ## Notice
/// This file contains **original implementation** in this repository for demonstration
/// and learning. It is **not** Apple sample code, **not** sponsored or endorsed by Apple,
/// and **Swift**, **SwiftUI**, and other Apple marks are trademarks of Apple Inc.
@Metadata(title: "Ripple Effect", description: "水面の波紋のような歪み効果", tags: [.metal])
struct RippleScreen: View {
    /// Regenerates each tap to retrigger the animation (new UUID per tap).
    @State private var trigger = UUID()
    /// Ripple center in view coordinates (tap location).
    @State private var origin = CGPoint.zero

    var body: some View {
        Image("waterwheel", bundle: .module)
            .resizable()
            .scaledToFit()
            // Apply ripple distortion via Metal shader.
            .modifier(RippleEffect(at: origin, trigger: trigger))
            .onTapGesture { location in
                // Store tap position and bump trigger to restart the animation.
                origin = location
                trigger = UUID()
            }
    }
}

// MARK: - RippleEffect

/// Drives the shader by linearly interpolating elapsed time from 0 to `duration`
/// with `keyframeAnimator`, then passing it to `RippleModifier`.
struct RippleEffect<Trigger: Equatable & Sendable>: ViewModifier {
    /// Ripple center in view coordinates.
    var origin: CGPoint
    /// Value that changes each time the animation should replay.
    var trigger: Trigger
    /// Total animation length in seconds.
    var duration: TimeInterval = 3

    init(at origin: CGPoint, trigger: Trigger) {
        self.origin = origin
        self.trigger = trigger
    }

    func body(content: Content) -> some View {
        // Local copies for closure capture semantics.
        let origin = origin
        let duration = duration

        // Replay keyframe animation whenever `trigger` changes.
        // `initialValue` 0.0 is interpolated into `elapsedTime`.
        content.keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, elapsedTime in
            view.modifier(RippleModifier(origin: origin, elapsedTime: elapsedTime, duration: duration))
        } keyframes: { _ in
            // Linearly interpolate from 0.0 to `duration` over `duration` seconds.
            MoveKeyframe(0.0)
            LinearKeyframe(duration, duration: duration)
        }
    }
}

// MARK: - RippleModifier

/// Applies Metal shader `Ripple::main` as a `layerEffect`.
/// `layerEffect` captures the view as a texture so the shader can offset sample positions.
///
/// - Note: Conceptual lineage and copyright notice for the WWDC reference appear on
///   ``RippleScreen`` and in `RippleShader.metal`.
private struct RippleModifier: ViewModifier {
    /// Ripple center in view coordinates.
    var origin: CGPoint
    var elapsedTime: TimeInterval
    var duration: TimeInterval
    /// Max pixel displacement (maps to shader `amplitude`).
    var amplitude: Double = 12
    /// Wave oscillation count (maps to shader `frequency`).
    var frequency: Double = 15
    /// Exponential decay rate (maps to shader `decay`).
    var decay: Double = 8
    /// Wave propagation speed in px/s (maps to shader `speed`).
    var speed: Double = 1200

    func body(content: Content) -> some View {
        // `layerEffect` runs the shader on the layer; `maxSampleOffset` bounds sampling.
        content.layerEffect(shader, maxSampleOffset: maxSampleOffset, isEnabled: isEnabled)
    }

    /// Binds arguments into a `Shader` for `Ripple::main`.
    private var shader: Shader {
        ShaderFunction(library: .module, name: "Ripple::main")(
            .float2(origin), // Ripple center
            .float(elapsedTime), // Elapsed time (seconds)
            .float(amplitude), // Max displacement
            .float(frequency), // Oscillation frequency
            .float(decay), // Decay rate
            .float(speed) // Propagation speed
        )
    }

    /// Largest offset the shader may sample; keep in sync with `amplitude`.
    private var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }

    /// Enable the shader only while the animation is running (not at start/end).
    private var isEnabled: Bool {
        elapsedTime > 0 && elapsedTime < duration
    }
}

#Preview {
    RippleScreen()
}
