#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

namespace FlowDistortion {
    float noise(float2 p, float time) {
        return sin(p.x * 10.0f) * sin(p.y * 10.0f + time * 0.5f) * 0.5f + 0.5f;
    }

    float2 curlNoise(float2 p, float time, float noiseScale) {
        constexpr float eps = 0.001f;
        float n1 = noise(p + float2(eps, 0.0f), time);
        float n2 = noise(p - float2(eps, 0.0f), time);
        float n3 = noise(p + float2(0.0f, eps), time);
        float n4 = noise(p - float2(0.0f, eps), time);

        float curlX = (n3 - n4) / (2.0f * eps);
        float curlY = (n2 - n1) / (2.0f * eps);
        return float2(curlY, -curlX) * noiseScale;
    }

    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float time, float distortionStrength, float damping, float noiseScale, float4 rect) {
        // UV正規化（[0,1]範囲）
        float2 uv = position / rect.zw;

        // アスペクト修正
        float2 aspect = rect.zw / min(rect.z, rect.w);
        uv = (uv - 0.5f) * aspect + 0.5f;

        // グリッドタイル（3x3繰り返し）
        float2 gridUv = fract(uv * 3.0f);

        // Multi-step advectionで歪み計算（後方トレース）
        float2 offset = float2(0.0f);
        constexpr int steps = 5;
        for (int i = 0; i < steps; ++i) {
            float2 flow = curlNoise(uv + offset - time * 0.1f, time, noiseScale) * distortionStrength;
            offset -= flow;
            offset *= damping; // 緩和でfluid-likeな減衰
        }

        // 歪んだUVをpositionに変換（サンプリング用）
        float2 distortedUv = gridUv + offset;
        float2 distortedPosition = distortedUv * rect.zw;

        // 入力レイヤーをサンプリング
        half4 color = layer.sample(distortedPosition);

        // Chromatic aberration（RGB分離）
        float aberStrength = length(offset) * 0.01f;
        float2 dir = normalize(offset);
        // オフセットをピクセル単位に
        float2 rOffset = dir * aberStrength * rect.zw;
        float2 bOffset = -rOffset;

        color.r = layer.sample(distortedPosition + rOffset).r;
        color.g = color.g; // 緑は変更なし
        color.b = layer.sample(distortedPosition + bOffset).b;
        return color;
    }
}
