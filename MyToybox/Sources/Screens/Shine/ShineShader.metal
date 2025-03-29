// https://x.com/YoheiNishitsuji/status/1857332718692094395
#include <metal_stdlib>
using namespace metal;

namespace Shine {
    /// The main fragment shader function that generates a dynamic shimmering pattern.
    /// The effect evolves over time using a procedural algorithm based on trigonometric
    /// transformations and iterative feedback loops.
    [[ stitchable ]]
    half4 main(float2 position, half4 color, float4 box, float sec) {
        float2 resolution = box.zw; // The width and height of the rendering area
        float i = 0.0, e = 0.0, intensity = 1.0, value = 0.0, output = 0.0;

        // Normalize position to a centered coordinate system scaled by resolution
        float2 posNormalized = (position * 2.0 - resolution) / resolution.x * 0.5;

        // Compute time-based values to control animation dynamics
        float tanValue = tan(sec * 0.5 + 0.5);
        float invTanValue = 1.0 / tanValue;

        // Outer loop creates layers of transformation over time
        for (output += 1; i++ < 60; output -= 0.022 / exp(e * 1e3)) {
            float3 p = float3(posNormalized * intensity, 0.0);
            p.z += invTanValue;
            e = p.z * intensity;

            // Inner loop applies multiple trigonometric transformations
            for (value = 2.0; value < 99;) {
                // Accumulate distortion based on cosine and resolution scaling
                e += abs(dot(cos(p.yx * value), sqrt(resolution / resolution / value)));
                value += value;

                // Rotate the 2D point using standard rotation matrix
                float angle = value;
                float sinAngle = sin(angle);
                float cosAngle = cos(angle);
                float2 rotated = float2(
                    p.x * cosAngle - p.y * sinAngle,
                    p.x * sinAngle + p.y * cosAngle
                );
                p.xy = rotated;
            }

            // Compute a reflection-based luminance effect
            float N = p.x * p.y;
            float I = e * 0.1;
            float N2 = N * N;
            float reflected = I - 2.0 * N2 * I;

            // Combine results to update intensity
            e = 0.15 + reflected * 1.5;
            intensity += e;
        }

        // Final grayscale value based on accumulated output
        half colorValue = half(output);
        return half4(colorValue, colorValue, colorValue, 1.0);
    }
}
