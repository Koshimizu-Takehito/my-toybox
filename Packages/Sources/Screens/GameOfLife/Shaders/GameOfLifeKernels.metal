#include <metal_stdlib>
using namespace metal;

// ============================================================================
// Compute: 1 step of Game of Life  (threadgroup-tiled, function-constant boundary)
// ============================================================================

/// Boundary mode selected at PSO creation time.
/// true = torus (wrap-around), false = clamp.
constant bool kWrap [[function_constant(0)]];

/**
 * @brief   Perform a single step update of Conway's Game of Life.
 *
 * Uses a 16x16 threadgroup with a 1-pixel halo (18x18 shared tile) to reduce
 * global texture reads from 9 per cell to ~1 per cell.  The boundary mode
 * (wrap / clamp) is resolved at compile time via `kWrap` function constant.
 *
 * @param src   Source grid (R8Uint). Cell value is taken from .r & 1u.
 * @param dst   Destination grid (R8Uint).
 * @param wh1   Packed width (x), height (y), dummy (z).
 * @param gid   Global thread position in the grid.
 * @param ltid  Local thread position in the threadgroup.
 * @param lsize Threadgroup size.
 */
kernel void lifeStep(
    texture2d<uint, access::read>  src   [[texture(0)]],
    texture2d<uint, access::write> dst   [[texture(1)]],
    constant uint3&                wh1   [[buffer(0)]],
    uint2                          gid   [[thread_position_in_grid]],
    uint2                          ltid  [[thread_position_in_threadgroup]],
    uint2                          lsize [[threads_per_threadgroup]]
) {
    const int W = int(wh1.x);
    const int H = int(wh1.y);

    // 18x18 shared tile = 16x16 core + 1-pixel halo on each side.
    constexpr int TILE = 18;
    threadgroup uint tile[TILE][TILE];

    const int2 tileOrigin = int2(gid) - int2(ltid) - 1;

    for (int j = int(ltid.y); j < TILE; j += int(lsize.y)) {
        for (int i = int(ltid.x); i < TILE; i += int(lsize.x)) {
            int2 gp = tileOrigin + int2(i, j);
            if (kWrap) {
                gp.x = ((gp.x % W) + W) % W;
                gp.y = ((gp.y % H) + H) % H;
            } else {
                gp = clamp(gp, int2(0), int2(W - 1, H - 1));
            }
            tile[j][i] = src.read(uint2(gp)).r & 1u;
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (int(gid.x) >= W || int(gid.y) >= H) return;

    const uint lx = ltid.x + 1;
    const uint ly = ltid.y + 1;

    uint s = tile[ly - 1][lx - 1] + tile[ly - 1][lx] + tile[ly - 1][lx + 1]
           + tile[ly    ][lx - 1] +                     tile[ly    ][lx + 1]
           + tile[ly + 1][lx - 1] + tile[ly + 1][lx] + tile[ly + 1][lx + 1];

    uint c = tile[ly][lx];
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
