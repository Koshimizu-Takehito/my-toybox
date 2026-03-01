#include <metal_stdlib>
using namespace metal;

namespace ComplexNumber {

    // MARK: - Complex Arithmetic

    inline float2 cmul(float2 a, float2 b) {
        return float2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
    }

    inline float2 cdiv(float2 a, float2 b) {
        float denom = dot(b, b);
        return float2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / denom;
    }

    inline float2 cexp(float2 z) {
        float r = exp(z.x);
        return float2(r * cos(z.y), r * sin(z.y));
    }

    inline float2 csin(float2 z) {
        return float2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y));
    }

    inline float2 cpow_int(float2 z, int n) {
        float2 result = float2(1.0, 0.0);
        for (int i = 0; i < n; i++) {
            result = cmul(result, z);
        }
        return result;
    }

    // MARK: - Preset Functions

    float2 evaluate(float2 z, int functionIndex) {
        switch (functionIndex) {
            case 0: // z^2
                return cmul(z, z);
            case 1: // 1 / (1 + z)
                return cdiv(float2(1.0, 0.0), float2(1.0 + z.x, z.y));
            case 2: // z^3 - 1
                return cpow_int(z, 3) - float2(1.0, 0.0);
            case 3: // sin(z)
                return csin(z);
            case 4: // exp(z)
                return cexp(z);
            case 5: // z^2 + c (c = -0.7 + 0.27i)
                return cmul(z, z) + float2(-0.7, 0.27);
            default:
                return z;
        }
    }

    // MARK: - HSV to RGB

    half3 hsv2rgb(half3 c) {
        half3 rgb = clamp(abs(fmod(c.x * 6.0h + half3(0.0h, 4.0h, 2.0h), 6.0h) - 3.0h) - 1.0h, 0.0h, 1.0h);
        return c.z * mix(half3(1.0h), rgb, c.y);
    }

    // MARK: - Main

    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float functionIndex) {
        // Pixel -> normalized [-1, 1] with aspect ratio preservation
        float2 uv = (position - box.zw * 0.5) / (min(box.z, box.w) * 0.5);

        // Scale to complex plane [-3, 3]
        float scale = 3.0;
        float2 z = uv * scale;

        // Evaluate complex function with interpolation
        int idx0 = int(floor(functionIndex));
        int idx1 = idx0 + 1;
        float t = functionIndex - float(idx0);
        float2 fz0 = evaluate(z, idx0);
        float2 fz1 = evaluate(z, idx1);
        float2 fz = mix(fz0, fz1, t);

        // Domain coloring: argument -> hue
        float arg = atan2(fz.y, fz.x);
        float hue = arg / (2.0 * M_PI_F) + 0.5;

        // Magnitude -> brightness via atan mapping [0, inf) -> [0, 1)
        float mag = length(fz);
        float brightness = atan(mag) / (M_PI_F * 0.5);

        half3 rgb = hsv2rgb(half3(half(hue), 0.65h, half(brightness)));

        // Draw grid lines at integer coordinates
        float pixelSize = scale * 2.0 / min(box.z, box.w);
        float gridThickness = 0.5 * pixelSize;
        float axisThickness = 1.0 * pixelSize;

        // Distance to nearest integer grid line
        float distToGridX = abs(z.x - round(z.x));
        float distToGridY = abs(z.y - round(z.y));
        float gridLineX = 1.0 - smoothstep(gridThickness * 0.5, gridThickness * 1.5, distToGridX);
        float gridLineY = 1.0 - smoothstep(gridThickness * 0.5, gridThickness * 1.5, distToGridY);
        float gridIntensity = max(gridLineX, gridLineY);

        // Coordinate axes (thicker)
        float xAxisLine = 1.0 - smoothstep(axisThickness * 0.5, axisThickness * 1.5, abs(z.y));
        float yAxisLine = 1.0 - smoothstep(axisThickness * 0.5, axisThickness * 1.5, abs(z.x));
        float axisIntensity = max(xAxisLine, yAxisLine);

        half3 gridColor = half3(0.3h);
        half3 axisColor = half3(0.15h);
        rgb = mix(rgb, gridColor, half(gridIntensity));
        rgb = mix(rgb, axisColor, half(axisIntensity));

        return half4(rgb, 1.0h);
    }
}
