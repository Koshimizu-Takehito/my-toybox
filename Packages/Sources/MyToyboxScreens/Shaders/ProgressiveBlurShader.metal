#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace ProgressiveBlur {
    /// Maximum blur radius supported by the kernel.
    constant int MAX_RADIUS = 100;

    /// 1D separable progressive Gaussian blur.
    /// Call twice (axis=0 for horizontal, axis=1 for vertical) to achieve
    /// a full 2D Gaussian blur in O(r) + O(r) instead of O(r^2).
    ///
    /// @param position  Fragment position in layer coordinates.
    /// @param layer     SwiftUI sampling layer.
    /// @param box       (cx, cy, width, height); height is used for progress.
    /// @param radius    Base blur radius (capped to MAX_RADIUS).
    /// @param axis      0.0 = horizontal pass, 1.0 = vertical pass.
    [[ stitchable ]] half4 progressiveBlur1D(
        float2 position,
        SwiftUI::Layer layer,
        float4 box,
        float radius,
        float axis
    ) {
        float ratio = clamp(position.y / box.w, 0.0, 1.0);
        radius *= smoothstep(0.0, 1.0, ratio);

        if (radius <= 0.0) return layer.sample(position);

        int r = min(int(radius), MAX_RADIUS);
        float sigma = max(radius / 3.0, 1e-3);
        float invTwoSigmaSq = -0.5 / (sigma * sigma);

        float2 step = (axis < 0.5) ? float2(1.0, 0.0) : float2(0.0, 1.0);

        half4 sum = half4(0.0h);
        float wsum = 0.0;
        for (int i = -r; i <= r; ++i) {
            float w = exp(float(i * i) * invTwoSigmaSq);
            sum  += half4(layer.sample(position + float(i) * step)) * half(w);
            wsum += w;
        }
        return sum / half(wsum);
    }
}
