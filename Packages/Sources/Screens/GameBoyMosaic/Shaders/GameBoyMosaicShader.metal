#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace GameBoyMosaic {
    // DMG palette stops (dark → light).
    constant half3 STOP0 = half3(0x0F, 0x38, 0x0F) / 255.0h;
    constant half3 STOP1 = half3(0x30, 0x62, 0x30) / 255.0h;
    constant half3 STOP2 = half3(0x8B, 0xAC, 0x0F) / 255.0h;
    constant half3 STOP3 = half3(0x9B, 0xBC, 0x0F) / 255.0h;
    constant half3 LUMA_WEIGHTS = half3(0.299h, 0.587h, 0.114h);

    inline half3 polylineMix(float t) {
        // Clamp segment index to [0, 2] so t == 1 maps to STOP3 (not STOP2).
        float pos = clamp(t, 0.0f, 1.0f) * 3.0f;
        float i = min(floor(pos), 2.0f);
        float f = pos - i;
        half3 a;
        half3 b;
        if (i < 1.0f) {
            a = STOP0;
            b = STOP1;
        } else if (i < 2.0f) {
            a = STOP1;
            b = STOP2;
        } else {
            a = STOP2;
            b = STOP3;
        }
        return mix(a, b, half(f));
    }

    /// Circular-dot mosaic with a Game Boy DMG green palette.
    ///
    /// - Parameters:
    ///   - position: Position in layer coordinates (points).
    ///   - layer: Source SwiftUI layer to sample.
    ///   - cellSize: Grid cell side length in points.
    ///   - colorCount: Number of palette levels in `[4, 256]`.
    ///   - rect: Bounding rect `(cx, cy, width, height)`.
    [[ stitchable ]] half4 main(
        float2 position,
        SwiftUI::Layer layer,
        float cellSize,
        float colorCount,
        float4 rect
    ) {
        float size = max(cellSize, 1.0f);

        // 1. Centered space (same as Mosaic).
        float2 p = position - rect.zw / 2.0f;
        float2 center = floor(p / size) * size + size / 2.0f;

        // 2. Sample in layer coordinates.
        half4 sample = layer.sample(center + rect.zw / 2.0f);
        half luma = dot(sample.rgb, LUMA_WEIGHTS);

        // 3–4. Quantize luminance onto the 4-stop polyline palette.
        float levels = max(colorCount, 2.0f);
        float index = floor(float(luma) * (levels - 1.0f) + 0.5f);
        half3 paletteColor = polylineMix(index / (levels - 1.0f));

        // 5. Circle test stays in centered space.
        if (length(p - center) > size * 0.45f) {
            return half4(STOP0, 1.0h);
        }
        return half4(paletteColor, 1.0h);
    }
}
