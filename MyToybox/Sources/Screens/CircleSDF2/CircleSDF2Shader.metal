#include <metal_stdlib>
using namespace metal;

namespace CircleSDF2Shader {
    float smoothMin(float x1, float x2, float k) {
        float h = clamp(0.5 - 0.5 * (x2 - x1) / k, 0.0, 1.0);
        return mix(x1, x2, h) - k * h * (1.0 - h);
    }

    float circleSDF(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float sec, float k) {
        float2 pos = -1.0 + 2.0 * (position + box.xy) / box.zw;
        if (box.z < box.w) {
            pos.y = pos.y * box.w / box.z;
        } else {
            pos.x = pos.x * box.z / box.w;
        }
        float tx = 0.5 * (1.0 + sin(2.0 * sec)) / 2.0;
        float ty = sin(sec);
        float sdf1 = circleSDF(pos, float2(tx, 0 + ty), k);
        float sdf2 = circleSDF(pos, float2(-tx, 0 - ty), k);
        float sdf3 = smoothMin(sdf1, sdf2, k);
        if (sdf3 < 0) {
            float value = 20 * abs(sdf3);
            if (abs(value - floor(value)) < 0.2) {
                return half4(1, 1, 1, 1);
            } else {
                return half4(0, 0.5, 1, 1);
            }
        }
        return half4(1, 1, 1, 1);
    }
}
