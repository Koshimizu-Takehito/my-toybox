#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Stitchable SwiftUI layer shader: radial ripple distortion (water-like).
///
/// ## Attribution
/// **Inspired by** Apple’s WWDC 2024 session *Create Custom Visual Effects with SwiftUI*
/// (session 10151, https://developer.apple.com/videos/play/wwdc2024/10151/). WWDC and
/// related Apple Developer content are **© Apple Inc.** All rights reserved by their
/// respective owners.
///
/// ## Notice
/// This shader is **original code** in this repository for demonstration; it is **not**
/// a redistribution of Apple sample code. **Swift**, **SwiftUI**, and other Apple marks
/// are trademarks of Apple Inc.
namespace Ripple {
    /// Ripple distortion effect (see namespace documentation for WWDC attribution).
    ///
    /// - Parameters:
    ///   - position: The pixel position in the view.
    ///   - layer: The SwiftUI layer to sample from.
    ///   - origin: The center point of the ripple (tap location).
    ///   - time: Elapsed time in seconds.
    ///   - amplitude: Maximum pixel displacement.
    ///   - frequency: Wave frequency.
    ///   - decay: Exponential decay rate.
    ///   - speed: Propagation speed in pixels per second.
    /// - Returns: The distorted color.
    [[ stitchable ]] half4 main(
        float2 position,
        SwiftUI::Layer layer,
        float2 origin,
        float time,
        float amplitude,
        float frequency,
        float decay,
        float speed
    ) {
        // Distance from this pixel to the ripple origin.
        float distance = length(position - origin);

        // Delay until the wave front reaches this pixel.
        float delay = distance / speed;
        time -= delay;
        time = max(0.0, time);

        // Ripple strength: sine wave modulated by exponential decay.
        float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);

        // Unit vector from origin outward.
        float2 n = normalize(position - origin);

        // Offset the sample position.
        float2 newPosition = position + rippleAmount * n;

        // Sample the layer at the displaced position.
        half4 color = layer.sample(newPosition);

        // Brightness boost for a subtle highlight (gloss).
        color.rgb += 0.3 * (rippleAmount / amplitude) * color.a;

        return color;
    }
}
