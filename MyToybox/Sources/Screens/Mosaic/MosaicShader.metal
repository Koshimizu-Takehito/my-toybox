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
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float scale) {
        // Snap the sampling position to a grid of `scale` size.
        position = floor(position / scale) * scale;

        // Sample the color at the snapped position to create a pixelated look.
        return layer.sample(position);
    }
}
