#include <metal_stdlib>
using namespace metal;

namespace CircleSDF2Shader {

    /// Computes a smooth minimum between two SDF values using blending factor `k`.
    float smoothMin(float x1, float x2, float k) {
        float h = clamp(0.5 - 0.5 * (x2 - x1) / k, 0.0, 1.0);
        return mix(x1, x2, h) - k * h * (1.0 - h);
    }

    /// Returns the signed distance from a point to a circle.
    float circleSDF(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

    /// The main fragment shader function.
    ///
    /// - Parameters:
    ///   - position: The pixel position in the view.
    ///   - color: (Unused) the input color.
    ///   - box: The view’s bounding box (origin + size).
    ///   - sec: Time or animation phase passed from SwiftUI.
    ///   - k: The smoothing factor for blending.
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float sec, float k) {
        // Normalize the coordinates from [0, screen size] to [-1, 1]
        float2 pos = -1.0 + 2.0 * (position + box.xy) / box.zw;

        // Apply aspect ratio correction
        if (box.z < box.w) {
            pos.y = pos.y * box.w / box.z;
        } else {
            pos.x = pos.x * box.z / box.w;
        }

        // Animated offsets for each circle
        float tx = 0.5 * (1.0 + sin(2.0 * sec)) / 2.0;
        float ty = sin(sec);

        // Compute SDFs for both circles
        float sdf1 = circleSDF(pos, float2(tx,  ty), k);
        float sdf2 = circleSDF(pos, float2(-tx, -ty), k);

        // Blend them using smoothMin
        float sdf3 = smoothMin(sdf1, sdf2, k);

        // Color the interior of the shape with a dashed effect
        if (sdf3 < 0) {
            float value = 20 * abs(sdf3);
            if (abs(value - floor(value)) < 0.2) {
                return half4(1, 1, 1, 1); // white stroke
            } else {
                return half4(0, 0.5, 1, 1); // cyan fill
            }
        }

        // Outside of shape: white background
        return half4(1, 1, 1, 1);
    }
}
