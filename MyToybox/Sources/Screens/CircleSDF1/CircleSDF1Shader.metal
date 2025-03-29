#include <metal_stdlib>
using namespace metal;

namespace CircleSDF1Shader {

    /// Returns a smooth minimum between two values using a blend factor `k`.
    /// This softens the hard edge that would normally appear when combining SDFs.
    float smoothMin(float x1, float x2, float k) {
        float h = clamp(0.5 - 0.5 * (x2 - x1) / k, 0.0, 1.0);
        return mix(x1, x2, h) - k * h * (1.0 - h);
    }

    /// Computes the signed distance from a point to a circle.
    float circleSDF(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

    /// The main fragment shader function.
    ///
    /// This function draws two animated circles and blends them using smoothMin.
    /// The circles move in opposite directions and their blend creates a fluid effect.
    ///
    /// - Parameters:
    ///   - position: The current pixel position in the view.
    ///   - color: Unused input color (can be ignored).
    ///   - box: A rectangle describing the bounding box of the view.
    ///   - sec: The elapsed time in seconds.
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float sec) {
        // Normalize pixel coordinates to [-1, 1], adjusting for aspect ratio.
        float2 pos = -1.0 + 2.0 * (position + box.xy) / box.zw;
        if (box.z < box.w) {
            pos.y = pos.y * box.w / box.z;
        } else {
            pos.x = pos.x * box.z / box.w;
        }

        // Calculate time-based offset for circle positions.
        float tx = 0.5 * (1.0 + sin(2.0 * sec)) / 2.0;
        float ty = 0.8 * sin(sec);

        // Calculate signed distances to two circles.
        float sdf1 = circleSDF(pos, float2(tx, ty), 0.3);
        float sdf2 = circleSDF(pos, float2(-tx, -ty), 0.3);

        // Blend the two SDFs using smooth minimum.
        float sdf3 = smoothMin(sdf1, sdf2, 0.3);

        // If inside either circle, draw blue-ish; otherwise, white.
        if (sdf3 < 0) {
            return half4(0.1, 0.5, 1.0, 1.0);
        }
        return half4(1.0, 1.0, 1.0, 1.0);
    }
}
