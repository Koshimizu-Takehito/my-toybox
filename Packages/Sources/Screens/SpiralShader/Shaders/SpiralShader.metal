#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace SpiralShader {
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float scale) {
        position = position - box.zw/2;
        position = position / (10 * scale);

        float r = length(position);
        float t = atan2(position.y, position.x);
        float offset = int(10 * t) % 2 ? 0 : M_PI_F;
        half3 value = int((sin((r + t + offset)) + 1)) % 2;
        return half4(value * color.xyz, 1.0);
    }
}
