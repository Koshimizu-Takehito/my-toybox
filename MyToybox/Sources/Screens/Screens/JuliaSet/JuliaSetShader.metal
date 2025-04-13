#include <metal_stdlib>
using namespace metal;

namespace JuliaSet {
    /// HSV -> RGB
    half3 hsv2rgb(half3 c) {
        half3 rgb = clamp(abs(fmod(c.x * 6.0 + half3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
        return c.z * mix(half3(1.0), rgb, c.y);
    }

    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float scale, float2 offset, float2 location) {
        position = - 1 + 2.0 * position / min(box.w, box.z); // [-1, 1]
        position /= pow(scale, 2); // [-1/pow(scale, 2), 1/pow(scale, 2)]

        position -= float2(0, 1/pow(scale, 2)) - 2.0 * location;

        // Zn (xは実部、yは虚部)
        float2 z = position.xy;
        // Zn+1 (xは実部、yは虚部)
        float2 zNext = float2(0);
        // 複素平面上の座標 (xは実部、yは虚部)
        float2 c = offset;
        bool diverge = false;
        int elapsed = 0;

        for (int i = 0; i < 10000; i++) {
            zNext.x = pow(z.x, 2) - pow(z.y, 2);
            zNext.y = 2.0 * z.x * z.y ;
            z = zNext + c;
            if (length(z) > 2.0) {
                diverge = true;
                break;
            }
            elapsed = i;
        }
        if (diverge) {
            half3 color = hsv2rgb(half3(half(elapsed + 200)/400, 0.7, 0.8));
            return half4(color, 1);
        } else {
            return half4(0.0, 0.0, 0.0, 1.0);
        }
    }
}
