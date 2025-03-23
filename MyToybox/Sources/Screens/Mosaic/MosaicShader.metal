#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace Mosaic {
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float scale) {
        position = floor(position / scale) * scale;
        return layer.sample(position);
    }
}
