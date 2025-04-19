#include <metal_stdlib>
using namespace metal;

namespace SmoothMin2d {
    float smoothMin(float x1, float x2, float k) {
        float h = clamp(0.5 - 0.5 * (x2 - x1) / k, 0.0, 1.0);
        return mix(x1, x2, h) - k * h * (1.0 - h);
    }

    float circleSDF(float2 point, float2 center, float radius) {
        return length(point - center) - radius;
    }

    half3 rgb(float sd1, float sd2, float sd3) {
        float t = atan(sd3) / __FLT_M_PI__ + 0.5;
        if (sd3 < 0) {
            half3 color1 = 1 - (abs(sd1)/0.4) * (1 - half3(1, 0, 1));
            half3 color2 = 1 - (abs(sd2)/0.4) * (1 - half3(0, 1, 1));
            return mix(color1, color2, t);
        }
        return mix(half3(0, 0, 1), half3(0.5, 1, 1), t);
    }
}

namespace SmoothMin2d {
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float sec, float k) {
        // Normalize pixel coordinates to [-1, 1], adjusting for aspect ratio.
        float2 pos = -1.0 + 2.0 * (position + box.xy) / box.zw;
        if (box.z < box.w) {
            pos.y = pos.y * box.w / box.z;
        } else {
            pos.x = pos.x * box.z / box.w;
        }
        float tx = 0.5 * (1 + sin(2 * sec))/2;
        float ty = 0.8 * sin(sec);
        float sd1 = circleSDF(pos, float2(tx, ty), 0.3);
        float sd2 = circleSDF(pos, float2(-tx, -ty), 0.3);
        float sd3 = smoothMin(sd1, sd2, k);
        return half4(rgb(sd1, sd2, sd3), 1.0);
    }
}
