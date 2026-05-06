#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace ImplicitEquation {
    /// Shader that renders an implicit equation f(x,y) = iso.
    /// - Parameters:
    ///   - position: Pixel position.
    ///   - layer: Unused (color effect mode).
    ///   - a: Radial frequency.
    ///   - b: Mix frequency.
    ///   - iso: Iso level.
    ///   - zoom: Zoom scale.
    ///   - rect: Bounding rect for UV calculation.
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float a, float b, float iso, float zoom, float4 rect) {
        // Normalize position to UV [-1..1] range, centered.
        float2 uv = (position - rect.zw / 2.0) / (min(rect.z, rect.w) / 2.0);
        uv /= zoom;  // Apply zoom (smaller zoom = wider view)

        // Implicit function: f(x,y) = sin(a * (x² + y²)) - cos(b * x * y)
        float x = uv.x;
        float y = uv.y;
        float r2 = x*x + y*y;
        float f = sin(a * r2) - cos(b * x * y);

        // Render as smooth lines where f ≈ iso
        float thickness = 0.02;  // Line thickness
        float aa = fwidth(f) * 2.0;  // Anti-aliasing factor
        float dist = abs(f - iso);
        half intensity = smoothstep(thickness + aa, thickness - aa, dist);
        if (sign(f - iso) < 0) {
            intensity = 1 - intensity;
        }
        half4 color = layer.sample(position);
        return half4(intensity * color.r, intensity * color.g, intensity * color.b, 1.0);
    }
}
