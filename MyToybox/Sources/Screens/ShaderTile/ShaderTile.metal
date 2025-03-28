#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace ShaderTile {
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float scale) {
        position = position - box.zw/2;
        position = position / (10 * scale);
        int2 xy = int2(floor(position)) % 2;
        if ((xy.x + xy.y) % 2) {
            return half4(0.0, 0.0, 0.0, 1.0);
        } else {
            return half4(0.8, 0.95, 1.0, 1.0);
        }
    }
}
