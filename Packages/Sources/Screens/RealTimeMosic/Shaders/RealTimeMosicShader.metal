#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace RealTimeMosicShader {
    /**
     * @file MosaicShader.metal
     * @brief Provides a simple, split-screen mosaic shader for SwiftUI.
     *
     * This file defines a `stitchable` Metal function that can be attached to a
     * SwiftUI `ShaderLibrary`. The shader applies a pixelated (mosaic) effect
     * to a configurable portion of the rendered layer while leaving the rest
     * of the image untouched.
     */

    /**
     * @brief Applies a pixelated mosaic effect to part of a SwiftUI layer.
     *
     * The shader renders the original image on the right-hand side of the view
     * and a pixelated version on the left-hand side. The split position is
     * controlled by the @p ratio parameter in normalized coordinates.
     *
     * Typical usage from SwiftUI is through `ShaderLibrary.mosaic`, passing in
     * the layer's bounding rectangle as @p bounds, the desired mosaic tile size
     * as @p scale, and a split value between `0.0` and `1.0` as @p ratio.
     *
     * @param position
     *     The fragment position in the layer's coordinate space.
     *
     * @param layer
     *     The SwiftUI layer being sampled. This is provided by SwiftUI and
     *     represents the rendered contents to which the effect is applied.
     *
     * @param bounds
     *     A rectangle describing the layer's bounds. The `xy` components usually
     *     represent the origin, while the `zw` components represent the width
     *     and height of the layer in points.
     *
     * @param scale
     *     The size of each mosaic tile, in points. Larger values produce a
     *     more heavily pixelated appearance.
     *
     * @param ratio
     *     The normalized horizontal split position in the range `[0.0, 1.0]`.
     *     Pixels with `position.x / bounds.z > ratio` are rendered without
     *     the mosaic effect; the remaining pixels are snapped to a grid to
     *     create the pixelated region.
     *
     * @return
     *     The resulting color after optionally applying the mosaic effect.
     */
    [[ stitchable ]] half4 main(float2 position, SwiftUI::Layer layer, float4 bounds, float scale, float ratio) {
        // Right-hand side of the view (beyond the split) is drawn as-is.
        if (position.x / bounds.z > ratio) {
            return layer.sample(position);
        }

        // Shift the position so that the layer is centered around the origin.
        position = position - bounds.zw / 2;

        // Snap the position to a regular grid of size `scale` to form tiles.
        position = floor(position / scale) * scale;

        // Sample the color at the snapped location, shifted back into layer space.
        // The extra `scale / 2` offsets sampling towards the center of each tile.
        return layer.sample(position + bounds.zw / 2 + scale / 2);
    }
}
