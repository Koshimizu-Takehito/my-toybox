#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace Mosaic {
    /// A simple mosaic shader that applies a pixelation effect
    /// by rounding positions to the nearest block center.
    ///
    /// - Parameters:
    ///   - position: The current pixel position on the layer.
    ///   - layer: The SwiftUI layer to be sampled.
    ///   - scale: The block size for the mosaic effect.
    /// - Returns: A single sampled color from the mosaic grid.
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float scale, float4 rect) {
        // Snap the sampling position to a grid of `scale` size.
        position = position - rect.zw / 2;
        position = floor((position) / scale) * scale;
        // Sample the color at the snapped position to create a pixelated look.
        return layer.sample(position + rect.zw / 2 + scale / 2);
    }
}
