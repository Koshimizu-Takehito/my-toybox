#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// MARK: - Kuwahara filter for SwiftUI Layer shaders
//
// Implements a classic 4-quadrant Kuwahara filter:
//   * For each pixel, consider four axis-aligned quadrants centered on the pixel.
//   * For each quadrant, accumulate mean RGB and compute luminance variance.
//   * Select the quadrant with the lowest luminance variance (edge-preserving),
//     then output that quadrant's mean color, optionally blended with the source.
//
// Coordinate space:
//   * SwiftUI supplies `position` in layer coordinates (top-left origin).
//   * We shift to a center-origin space to iterate symmetric neighborhoods.
//   * `rect` packs (cx, cy, width, height); only width/height are used here.
//
// Color model:
//   * Luminance weights (Rec.601): (0.299, 0.587, 0.114).
//
// Performance:
//   * The effective radius is clamped to [1, 16] to bound the O(r^2) work per pixel.
//   * Sampling coordinates are explicitly clamped to the layer rect; no off-rect reads.
//
// Parameters (stitched from Swift):
//   - `radius` (float): UI-provided radius, clamped here to [1, 16].
//   - `rect`   (float4): (cx, cy, width, height); width/height are used.
//   - `blend`  (float):  linear mix 0.0 (source) … 1.0 (filtered).
namespace Kuwahara {
    // Luma weights used to scalarize RGB variance to luminance variance.
    constant float3 LUMA = float3(0.299, 0.587, 0.114);

    // Clamp a position to the layer rectangle in center-origin coordinates.
    inline float2 clampToRect(float2 p, float4 rectCenterSize) {
        float2 halfSize = rectCenterSize.zw * 0.5;
        float2 minP = -halfSize;
        float2 maxP =  halfSize;
        return clamp(p, minP, maxP);
    }

    // Accumulate mean and mean of squares over a single quadrant.
    inline void accumulateQuadrant(
        SwiftUI::Layer layer,
        float2 posCenter,   // Current position in center-origin space
        int r,              // Integer radius
        int x0, int x1,     // Inclusive range on x
        int y0, int y1,     // Inclusive range on y
        float4 rect,        // (cx, cy, w, h); only w/h are used
        thread float3 &sum, thread float3 &sum2, thread int &count
    ) {
        for (int j = y0; j <= y1; ++j) {
            for (int i = x0; i <= x1; ++i) {
                float2 p = posCenter + float2(i, j);
                p = clampToRect(p, rect);
                // Convert back to top-left origin space for sampling.
                half4 c = layer.sample(p + rect.zw * 0.5);
                float3 rgb = float3(c.r, c.g, c.b);
                sum  += rgb;
                sum2 += rgb * rgb;
                count += 1;
            }
        }
    }

    /// Shader entry point (stitched from SwiftUI).
    /// - Parameters:
    ///   - position: Fragment position in layer coordinates (top-left origin).
    ///   - layer:    SwiftUI sampling layer.
    ///   - radius:   Sampling radius; clamped to [1, 16].
    ///   - rect:     (cx, cy, width, height); width/height are used.
    ///   - blend:    Mix 0.0 (source) … 1.0 (filtered).
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float radius, float4 rect, float blend) {
        // Shift to center-origin coordinates.
        float2 pos = position - rect.zw * 0.5;

        // Radius used by loops (hard-clamped for safety/complexity bounds).
        int r = max(1, (int)round(radius));
        r = min(r, 16); // Example safety cap to avoid heavy computation.

        // Compute statistics for the 4 quadrants.
        float3 mean[4];
        float  varS[4]; // Luminance variance scalar
        for (int k = 0; k < 4; ++k) { mean[k] = float3(0); varS[k] = 0.0; }

        // Q0: x[-r..0], y[-r..0]
        {
            float3 sum = float3(0), sum2 = float3(0);
            int count = 0;
            accumulateQuadrant(layer, pos, r, -r, 0, -r, 0, rect, sum, sum2, count);
            float3 m = sum / max(1, count);
            float3 v = sum2 / max(1, count) - m * m;
            mean[0] = m;
            // Use luminance variance (alternatively, dot(v, 1) to combine channel variances).
            varS[0] = max(0.0, dot(v, LUMA));
        }
        // Q1: x[0..r], y[-r..0]
        {
            float3 sum = float3(0), sum2 = float3(0);
            int count = 0;
            accumulateQuadrant(layer, pos, r, 0, r, -r, 0, rect, sum, sum2, count);
            float3 m = sum / max(1, count);
            float3 v = sum2 / max(1, count) - m * m;
            mean[1] = m;
            varS[1] = max(0.0, dot(v, LUMA));
        }
        // Q2: x[-r..0], y[0..r]
        {
            float3 sum = float3(0), sum2 = float3(0);
            int count = 0;
            accumulateQuadrant(layer, pos, r, -r, 0, 0, r, rect, sum, sum2, count);
            float3 m = sum / max(1, count);
            float3 v = sum2 / max(1, count) - m * m;
            mean[2] = m;
            varS[2] = max(0.0, dot(v, LUMA));
        }
        // Q3: x[0..r], y[0..r]
        {
            float3 sum = float3(0), sum2 = float3(0);
            int count = 0;
            accumulateQuadrant(layer, pos, r, 0, r, 0, r, rect, sum, sum2, count);
            float3 m = sum / max(1, count);
            float3 v = sum2 / max(1, count) - m * m;
            mean[3] = m;
            varS[3] = max(0.0, dot(v, LUMA));
        }

        // Choose the quadrant with the minimum variance.
        int idx = 0;
        float minVar = varS[0];
        for (int k = 1; k < 4; ++k) {
            if (varS[k] < minVar) { minVar = varS[k]; idx = k; }
        }

        // Source color and blended output.
        half4 src = layer.sample(position);
        float3 dstRGB = mix(float3(src.rgb), mean[idx], clamp(blend, 0.0, 1.0));

        return half4(half3(dstRGB), src.a);
    }
}
