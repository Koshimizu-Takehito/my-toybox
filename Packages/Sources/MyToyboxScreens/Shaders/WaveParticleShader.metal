#include <metal_stdlib>
using namespace metal;

#define PI2 6.28318530718

namespace WaveParticle {
    [[stitchable]] half4 main(float2 position, half4 color, float4 box, float sec) {
        color = 0;
        half2 origin = half2(box.x, box.y);
        half2 size   = half2(box.z, box.w);
        half2 localCoord = half2(position) - origin;
        half2 p = ( localCoord - 0.5 * size ) / size.y * 0.8;
        half3 baseColor = half3(color.r, color.g, color.b) * 0.9 - half3(0.002);
        half N = 200.0;
        for (half i = 0.0; i < N; i++) {
            half freq = fmod(sec / 9.0 + tan(i / N) + 1.0, 0.35);
            half2 angle = half2(i, i)
                           + PI2 * half2(0.0, 0.25)
                           + 0.1 * normalize(half2(i, 0.1 * sec + 1.0));
            half2 s = half2(sin(angle.x), sin(angle.y));
            half2 q = freq * s;
            half d = exp(0.47 - length(q));
            half distFactor = 4 * exp(-100.0 * (d + 0.04) * length(p - q));
            baseColor += half3(0.0, 0.5, 0.8) * distFactor;
        }
        return half4(clamp(baseColor, 0.0, 1.0), 1.0);
    }
}
