/*
 Inspired by: Yohei Nishitsuji (@YoheiNishitsuji)
 https://x.com/YoheiNishitsuji/status/1928677024131895624

 This Metal shader is adapted and documented based on the original pattern.
*/

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace CosmicWeb {
    /// Returns a 2D rotation matrix for the given angle (in radians).
    float2x2 rotate2D(float angle) {
        float c = cos(angle);
        float s = sin(angle);
        return float2x2(c, -s, s,  c);
    }

    /// Main Metal shader function that generates a cosmic web pattern.
    /// - Parameters:
    ///   - position: The current pixel position in the layer.
    ///   - layer: SwiftUI layer information.
    ///   - box: The bounding rectangle (origin.xy, size.zw).
    ///   - secs: The current animation time in seconds.
    /// - Returns: The final pixel color (half4).
    [[ stitchable ]]
    half4 main(float2 position, SwiftUI::Layer layer, float4 box, float secs) {
        // Normalize pixel coordinates to center origin and scale.
        position = ((position + position - box.zw) / max(box.z, box.w)) * 0.6;
        float intensity = 0.0;
        float scale = 6.0;
        float2 noise = float2(0.0, 0.0);
        float2 patternCoord = float2(0.0, 0.0);

        // Iteratively compose the web-like pattern by layering rotated and scaled waves.
        for (float i = 0.0; i < 129; i += 1.0) {
            position = position * rotate2D(4.95);
            noise = noise * rotate2D(4.8 + sin(secs) * 0.05);
            noise += float2(1.0, 0.0) * rotate2D(secs) * 0.035;
            patternCoord = position * scale * i + noise;
            intensity += dot(float2(1.0, 1.0), sin(patternCoord) / scale * 2.5);
            noise += cos(patternCoord);
            scale *= 1.08;
        }
        // Final intensity adjustment, includes radial attenuation from center.
        intensity = 0.4 - intensity * 0.3 - dot(position, position);
        // Output grayscale color based on computed intensity.
        return half4(half3(intensity * 0.9), 1.0);
    }
}
