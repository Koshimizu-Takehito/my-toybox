#include <metal_stdlib>
using namespace metal;

// ============================================================================
// Compute: 1 step of Game of Life
// ============================================================================

/**
 * @brief   Perform a single step update of Conway's Game of Life.
 *
 * @param src   Source grid (R8Uint). Cell value is taken from .r & 1u.
 * @param dst   Destination grid (R8Uint).
 * @param wh1   Packed width (x), height (y), dummy (z).
 * @param wrap  Boundary mode. 0 = clamp, 1 = torus (wrap-around).
 * @param gid   Global thread position in the grid.
 * @param ltid  Local thread position in the threadgroup (unused).
 * @param gsize Total grid size in threads (unused).
 * @param lsize Threadgroup size (unused).
 *
 * The kernel reads the eight neighbors of each cell and writes the next state
 * according to the Game of Life rules:
 *  - Live cell survives with 2 or 3 neighbors.
 *  - Dead cell becomes live with exactly 3 neighbors.
 */
kernel void lifeStep(
    texture2d<uint, access::read>  src   [[texture(0)]],
    texture2d<uint, access::write> dst   [[texture(1)]],
    constant uint3&                wh1   [[buffer(0)]], // width, height, dummy
    constant uint&                 wrap  [[buffer(1)]], // 0: clamp, 1: torus
    uint2                          gid   [[thread_position_in_grid]],
    uint2                          ltid  [[thread_position_in_threadgroup]],
    uint2                          gsize [[threads_per_grid]],
    uint2                          lsize [[threads_per_threadgroup]]
) {
    const uint W = wh1.x;
    const uint H = wh1.y;
    if (gid.x >= W || gid.y >= H) {
        return;
    }

    // Neighbor reader (integer coordinates).
    auto r = [&](int x, int y) -> uint {
        int ix = x, iy = y;
        if (wrap == 1) {
            ix = (ix % int(W) + int(W)) % int(W);
            iy = (iy % int(H) + int(H)) % int(H);
        } else {
            ix = clamp(ix, 0, int(W) - 1);
            iy = clamp(iy, 0, int(H) - 1);
        }
        return src.read(uint2(ix, iy)).r & 1u;
    };

    const int x = int(gid.x);
    const int y = int(gid.y);

    uint s =
        r(x - 1, y - 1) + r(x, y - 1) + r(x + 1, y - 1) +
        r(x - 1, y    ) +                 r(x + 1, y    ) +
        r(x - 1, y + 1) + r(x, y + 1) + r(x + 1, y + 1);

    uint c = src.read(uint2(gid)).r & 1u;
    uint n = (c == 1u) ? ((s == 2u || s == 3u) ? 1u : 0u)
                       : ((s == 3u) ? 1u : 0u);
    dst.write(n, gid);
}

// ============================================================================
// Render: Fullscreen blit with zoom/pan
// ============================================================================

/**
 * @brief  Vertex output structure for fullscreen blit.
 */
struct VSOut {
    float4 position [[position]];
    float2 uv;
};

/**
 * @brief  Fullscreen triangle vertex shader (3-vertex trick).
 *
 * Generates positions/UVs to cover the whole screen without a vertex buffer.
 *
 * @param vid Vertex ID (0..2).
 * @return    Position/UV pair.
 */
vertex VSOut fullscreenQuadVS(uint vid [[vertex_id]]) {
    // 3 頂点（三角形）でフルスクリーンを覆う（頂点バッファ不要）
    float2 pos[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0),
    };
    float2 uv[3] = {
        float2(0.0, 0.0),
        float2(2.0, 0.0),
        float2(0.0, 2.0),
    };

    VSOut out;
    out.position = float4(pos[vid], 0.0, 1.0);
    out.uv = uv[vid];
    return out;
}

/**
 * @brief  Per-view uniforms for blit and cell styling.
 *
 * @note
 *  - `pad` はセル内パディング（片側率）。0.0〜0.5 の範囲を想定。
 */
struct ViewUniforms {
    uint   width;       ///< Grid width (cells)
    uint   height;      ///< Grid height (cells)
    float  scale;       ///< View scale (>= 1.0)
    float2 location;    ///< View center in normalized space (-0.5 .. 0.5)
    float2 offset;      ///< Additional offset (optional)
    float4 foreground;  ///< RGBA color for live cells
    float4 background;  ///< RGBA color for background
    float  pad;         ///< Cell padding ratio per side (0.0 .. 0.5)
};

/**
 * @brief  Fragment shader for blitting the grid with zoom/pan and padding.
 *
 * @param in    Vertex-to-fragment payload.
 * @param grid  R8Uint grid texture. Cell state is stored in .r LSB.
 * @param U     View uniforms.
 * @return      RGBA color.
 */
fragment float4 lifeBlitFS(
    VSOut                 in     [[stage_in]],
    texture2d<uint>       grid   [[texture(0)]],
    constant ViewUniforms& U     [[buffer(0)]]
) {
    float2 uv = in.uv - 0.5;
    uv /= max(1.0, U.scale);
    uv += 0.5 - U.location + U.offset;

    float2 xy = uv * float2(U.width, U.height);
    int2 ij = int2(floor(xy));

    if (ij.x < 0 || ij.y < 0 || ij.x >= int(U.width) || ij.y >= int(U.height)) {
        return U.background;
    }

    // Fractional coordinate in-cell (0..1).
    float2 frac = fract(xy);

    // Read live/dead state.
    uint v = grid.read(uint2(ij)).r & 1u;

    if (v == 1u) {
        // 片側 U.pad（例: 0.05 = 5%）を余白として背景色で塗る。
        if (frac.x < U.pad || frac.x > (1.0 - U.pad) ||
            frac.y < U.pad || frac.y > (1.0 - U.pad)) {
            return U.background;
        }
        return U.foreground;
    } else {
        // デッドセルは背景色。
        return U.background;
    }
}
