#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

namespace TileShader {
    /// A Metal shader that renders a checkerboard tile effect using position-based logic.
    ///
    /// This function divides the space into a 2×2 grid, and alternates between black and the original color
    /// based on the tile position, effectively creating a checkerboard pattern.
    ///
    /// The `scale` input dynamically adjusts the zoom level of the pattern.
    ///
    /// - Parameters:
    ///   - position: The current pixel position in the view.
    ///   - color: The base color provided by SwiftUI.
    ///   - box: The bounding rectangle of the layer.
    ///   - scale: A floating-point value controlling the tile size.
    ///
    /// - Returns: The modified color for this pixel.
    [[ stitchable ]] half4 main(float2 position, half4 color, float4 box, float scale) {
        // Shift position origin to the center of the box
        position = position - box.zw / 2;

        // Apply scaling to control zoom level
        position = position / (10 * scale);

        // Convert position to tile coordinates
        int2 xy = int2(floor(position)) % 2;

        // Alternate colors in a checkerboard pattern
        if ((xy.x + xy.y) % 2) {
            // Black tile
            return half4(0.0, 0.0, 0.0, 1.0);
        } else {
            // Original color
            return color;
        }
    }
}
