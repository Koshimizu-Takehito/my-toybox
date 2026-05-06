#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

/// PrettyHip shader effect.
///
/// - Parameters:
///   - position: The pixel position in the view.
///   - color: The current color at this position.
///   - box: The bounding rectangle of the layer.
///   - time: Elapsed time in seconds.
/// - Returns: The modified color.
static inline float fractf(float x) {
    return x - floor(x);
}

static inline float2 fractf(float2 x) {
    return x - floor(x);
}

static inline float stepf(float edge, float x) {
    return x < edge ? 0.0 : 1.0;
}

static inline float smoothstepf(float edge0, float edge1, float x) {
    float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

static inline float mixf(float a, float b, float t) {
    return a + (b - a) * t;
}

static inline float4 mixf(float4 a, float4 b, float t) {
    return a + (b - a) * t;
}

[[stitchable]] half4 prettyHip(float2 position, half4 color, float4 box, float time) {
    (void)color;

    // Shadertoy-style inputs:
    float2 iResolution = box.zw;
    float iTime = time;
    // SwiftUI `position` is in layer coords (top-left origin). Convert to Shadertoy-style fragCoord:
    // - subtract box origin (defensive; usually 0)
    // - flip Y to bottom-left origin
    // - add 0.5 to sample pixel centers (closer to Shadertoy convention)
    float2 p = position - box.xy;
    float2 fragCoord = float2(p.x + 0.5, (iResolution.y - p.y) - 0.5);

    // Ported from GLSL (mainImage)
    float aspect = iResolution.y / iResolution.x;

    float2 uv = fragCoord / iResolution.x;
    uv -= float2(0.5, 0.5 * aspect);

    const float kDegToRad = 0.017453292519943295f; // pi / 180
    float rot = 45.0 * kDegToRad; // (45deg) // 45.0*sin(iTime) if you want animation
    float c = cos(rot);
    float s = sin(rot);
    uv = float2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);

    uv += float2(0.5, 0.5 * aspect);
    uv.y += 0.5 * (1.0 - aspect);

    float2 pos = 10.0 * uv;
    float2 rep = fractf(pos);
    float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
    float squareDist = length((floor(pos) + float2(0.5)) - float2(5.0));

    float edge = (iTime - squareDist * 0.5) * 0.5;
    edge = 2.0 * fractf(edge * 0.5);

    float value = fractf(dist * 2.0);
    value = mixf(value, 1.0 - value, stepf(1.0, edge));

    edge = pow(fabs(1.0 - edge), 2.0);
    value = smoothstepf(edge - 0.05, edge, 0.95 * value);

    value += squareDist * 0.1;

    float4 colA = float4(1.0, 1.0, 1.0, 1.0);
    float4 colB = float4(0.5, 0.75, 1.0, 1.0);
    float4 outColor = mixf(colA, colB, value);
    // Note: In Shadertoy the alpha channel is typically not used for compositing.
    // SwiftUI *does* composite with alpha, so we output opaque color to match the expected look.
    (void)clamp(value, 0.0, 1.0); // keep the math reference

    return half4(half3(outColor.rgb), half(1.0));
}
