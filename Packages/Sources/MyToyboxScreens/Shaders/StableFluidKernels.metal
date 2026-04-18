// Attribution
// -----------
// The stable fluid simulation algorithm is based on:
//   Jos Stam, "Stable Fluids," SIGGRAPH 1999.
//
// This Metal implementation is inspired by the WebGPU (TypeScript) example in:
//   TypeGPU — Copyright (c) 2025 Software Mansion — MIT License
//   https://github.com/software-mansion/TypeGPU
//   apps/typegpu-docs/src/examples/simulation/stable-fluid/

#include <metal_stdlib>
using namespace metal;

// ============================================================================
// Shared types
// ============================================================================

/**
 * @brief  Simulation parameters shared across multiple compute kernels.
 *         複数のコンピュートカーネルで共有されるシミュレーションパラメータ。
 *
 * Memory layout must match the Swift `SimParamsBuffer` struct exactly.
 * メモリレイアウトは Swift の `SimParamsBuffer` 構造体と正確に一致する必要がある。
 */
struct SimParams {
    float deltaTime; ///< Discrete time step (dimensionless). 離散時間刻み幅（無次元）。
    float viscosity; ///< Kinematic viscosity coefficient (dimensionless). 動粘性係数（無次元）。
};

/**
 * @brief  Brush input state passed from the CPU each frame.
 *         毎フレーム CPU から渡されるブラシ入力状態。
 */
struct BrushParams {
    int2   pos;        ///< Brush center in grid-cell coordinates. グリッドセル座標のブラシ中心。
    float2 delta;      ///< Per-frame movement direction (grid cells). フレーム間移動方向（グリッドセル単位）。
    float  radius;     ///< Gaussian falloff radius (grid cells). ガウス減衰半径（グリッドセル単位）。
    float  forceScale; ///< Force vector multiplier. 力ベクトルの倍率。
    float  inkAmount;  ///< Peak ink deposit at brush center. ブラシ中心でのインク注入ピーク値。
};

// ============================================================================
// Helpers
// ============================================================================

/**
 * @brief  Clamp a 2D integer coordinate into valid texture bounds [0, bounds-1].
 *         2D 整数座標をテクスチャの有効範囲 [0, bounds-1] にクランプする。
 *
 * Used by stencil-based kernels (diffusion, divergence, pressure, project) to
 * handle boundary pixels without going out of range.
 * ステンシルベースのカーネル（拡散、発散、圧力、射影）で境界ピクセルの
 * 範囲外アクセスを防ぐために使用。
 *
 * @param coord   The coordinate to clamp. クランプ対象の座標。
 * @param bounds  Texture dimensions (width, height). テクスチャサイズ（幅, 高さ）。
 * @return        Clamped coordinate. クランプ済み座標。
 */
static inline int2 clampCoord(int2 coord, int2 bounds) {
    return clamp(coord, int2(0), bounds - 1);
}

/// Load an 18x18 tile (16x16 core + 1-pixel halo) from a float4 texture into
/// threadgroup memory with clamped boundary handling.
static inline void loadTile4(
    threadgroup float4 tile[18][18],
    texture2d<float, access::read> src,
    uint2 ltid, uint2 lsize, uint2 gid, int2 bounds
) {
    const int2 origin = int2(gid) - int2(ltid) - 1;
    for (int j = int(ltid.y); j < 18; j += int(lsize.y)) {
        for (int i = int(ltid.x); i < 18; i += int(lsize.x)) {
            int2 gp = clampCoord(origin + int2(i, j), bounds);
            tile[j][i] = src.read(uint2(gp));
        }
    }
}

// ============================================================================
// Compute: Brush – generate force and ink from touch input
// ============================================================================

/**
 * @brief  Generate force and ink fields from the user's touch position.
 *         ユーザーのタッチ位置から力場とインク場を生成する。
 *
 * For each grid cell, computes the distance to the brush center and applies
 * a **Gaussian falloff**: `w = exp(-d^2 / r^2)`.
 * 各グリッドセルについて、ブラシ中心からの距離を計算し、
 * **ガウス減衰** `w = exp(-d^2 / r^2)` を適用する。
 *
 * - Force vector: `forceScale * w * delta` (points in the drag direction).
 * - Ink deposit: `inkAmount * w` (scalar, strongest at center, fading outward).
 * - 力ベクトル: `forceScale * w * delta`（ドラッグ方向を向く）。
 * - インク注入: `inkAmount * w`（スカラー、中心が最も強く外側へ減衰）。
 *
 * The Gaussian ensures a smooth, natural-looking brush rather than a hard circle.
 * ガウス関数によりハードな円ではなく、滑らかで自然な見た目のブラシになる。
 *
 * @param forceDst  Output force texture (float2 in .rg). 出力力テクスチャ（.rg に float2）。
 * @param inkDst    Output ink texture (scalar in .r). 出力インクテクスチャ（.r にスカラー）。
 * @param brush     Brush parameters from the CPU. CPU からのブラシパラメータ。
 * @param gid       Thread position = grid cell coordinate. スレッド位置＝グリッドセル座標。
 */
kernel void fluidBrush(
    texture2d<float, access::write> forceDst [[texture(0)]],
    texture2d<float, access::write> inkDst   [[texture(1)]],
    constant BrushParams&           brush    [[buffer(0)]],
    uint2                           gid      [[thread_position_in_grid]]
) {
    float dx = float(gid.x) - float(brush.pos.x);
    float dy = float(gid.y) - float(brush.pos.y);
    float distSq = dx * dx + dy * dy;
    float radiusSq = brush.radius * brush.radius;

    float2 forceVec = float2(0.0);
    float  ink = 0.0;

    if (distSq < radiusSq) {
        float w = exp(-distSq / radiusSq);
        forceVec = brush.forceScale * w * brush.delta;
        ink = brush.inkAmount * w;
    }

    forceDst.write(float4(forceVec, 0.0, 1.0), gid);
    inkDst.write(float4(ink, 0.0, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Add ink to density field
// ============================================================================

/**
 * @brief  Accumulate newly deposited ink into the existing density field.
 *         新たに注入されたインクを既存の密度場に加算する。
 *
 * Simple per-pixel addition: `dst = src + add`.
 * 単純なピクセルごとの加算: `dst = src + add`。
 *
 * @param src  Current ink density field. 現在のインク密度場。
 * @param add  Newly generated ink (from fluidBrush). 新たに生成されたインク（fluidBrush から）。
 * @param dst  Output ink density field. 出力インク密度場。
 * @param gid  Thread position. スレッド位置。
 */
kernel void fluidAddInk(
    texture2d<float, access::read>  src [[texture(0)]],
    texture2d<float, access::read>  add [[texture(1)]],
    texture2d<float, access::write> dst [[texture(2)]],
    uint2                           gid [[thread_position_in_grid]]
) {
    float srcVal = src.read(gid).x;
    float addVal = add.read(gid).x;
    dst.write(float4(srcVal + addVal, 0.0, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Add forces to velocity field
// ============================================================================

/**
 * @brief  Apply external forces to the velocity field using explicit Euler integration.
 *         明示的オイラー積分で速度場に外力を適用する。
 *
 * Euler step: `v_new = v_old + Δt * F`
 * オイラーステップ: `v_new = v_old + Δt * F`
 *
 * This is the simplest time integration scheme. The force field `F` is
 * generated by `fluidBrush` and represents the user's drag input.
 * これは最も単純な時間積分スキーム。力場 `F` は `fluidBrush` が生成し、
 * ユーザーのドラッグ入力を表す。
 *
 * @param src    Current velocity field. 現在の速度場。
 * @param force  External force field from brush. ブラシからの外力場。
 * @param dst    Output velocity field. 出力速度場。
 * @param p      Simulation parameters (`deltaTime` used here). シミュレーションパラメータ（`deltaTime` を使用）。
 * @param gid    Thread position. スレッド位置。
 */
kernel void fluidAddForces(
    texture2d<float, access::read>  src   [[texture(0)]],
    texture2d<float, access::read>  force [[texture(1)]],
    texture2d<float, access::write> dst   [[texture(2)]],
    constant SimParams&             p     [[buffer(0)]],
    uint2                           gid   [[thread_position_in_grid]]
) {
    float2 vel = src.read(gid).xy;
    float2 f   = force.read(gid).xy;
    float2 out = vel + p.deltaTime * f;
    dst.write(float4(out, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Advect velocity (Semi-Lagrangian with bilinear sampling)
// ============================================================================

/**
 * @brief  Self-advect the velocity field using the Semi-Lagrangian method.
 *         Semi-Lagrangian 法で速度場を自己移流する。
 *
 * **Physics:**
 * Advection is the transport of a quantity by the flow itself. For the
 * velocity field, this means "the fluid carries its own velocity along".
 * **物理：**
 * 移流とは、流れ自身による物理量の輸送。速度場では
 * 「流体が自身の速度を運ぶ」ことを意味する。
 *
 * **Algorithm (Semi-Lagrangian, Jos Stam 1999):**
 *   1. For each grid cell, read its current velocity v.
 *   2. Trace a virtual particle **backward** in time: `prev = pos - Δt * v`.
 *   3. Sample the velocity at that previous position using bilinear interpolation.
 *   4. Write the sampled value as the new velocity at the current cell.
 *
 * **アルゴリズム（Semi-Lagrangian、Jos Stam 1999）：**
 *   1. 各グリッドセルの現在の速度 v を読む。
 *   2. 仮想粒子を時間的に **後方** に追跡: `prev = pos - Δt * v`。
 *   3. その前位置での速度をバイリニア補間でサンプリング。
 *   4. サンプリングした値を現在のセルの新しい速度として書き込む。
 *
 * This method is **unconditionally stable** regardless of Δt, unlike
 * explicit Eulerian schemes that blow up when Δt is too large.
 * この方法は Δt に関係なく **無条件安定** である。Δt が大きすぎると
 * 発散する明示的オイラー法とは異なる。
 *
 * Boundary cells are zeroed to enforce a no-slip (zero velocity) boundary.
 * 境界セルはゼロに設定され、滑りなし（速度ゼロ）境界条件を適用する。
 *
 * @param src   Current velocity field (sampled with bilinear filtering). 現在の速度場（バイリニアフィルタリングでサンプリング）。
 * @param dst   Output velocity field. 出力速度場。
 * @param samp  Linear sampler for bilinear interpolation. バイリニア補間用リニアサンプラー。
 * @param p     Simulation parameters (`deltaTime`). シミュレーションパラメータ（`deltaTime`）。
 * @param gid   Thread position. スレッド位置。
 */
kernel void fluidAdvect(
    texture2d<half, access::sample> src    [[texture(0)]],
    texture2d<float, access::write> dst    [[texture(1)]],
    sampler                         samp   [[sampler(0)]],
    constant SimParams&             p      [[buffer(0)]],
    uint2                           gid    [[thread_position_in_grid]]
) {
    uint w = src.get_width();
    uint h = src.get_height();

    if (gid.x <= 0 || gid.y <= 0 || gid.x >= w - 1 || gid.y >= h - 1) {
        dst.write(float4(0.0, 0.0, 0.0, 1.0), gid);
        return;
    }

    float2 vel = float2(src.read(gid).xy);
    float2 prevPos = float2(gid) - p.deltaTime * vel;
    float2 clamped = clamp(prevPos, float2(-0.5), float2(float(w), float(h)) - 0.5);
    float2 uv = (clamped + 0.5) / float2(float(w), float(h));
    float4 sampled = float4(src.sample(samp, uv));
    dst.write(sampled, gid);
}

// ============================================================================
// Compute: Diffusion (Jacobi iteration)
// ============================================================================

/**
 * @brief  Perform one Jacobi iteration of the viscous diffusion equation.
 *         粘性拡散方程式のヤコビ反復を 1 回実行する。
 *
 * **Physics:**
 * Viscous diffusion models how momentum spreads through the fluid due to
 * internal friction. The diffusion equation is: `∂v/∂t = nu * Laplacian(v)`,
 * where nu is the kinematic viscosity.
 * **物理：**
 * 粘性拡散は、内部摩擦により運動量が流体中に広がる様子をモデル化する。
 * 拡散方程式: `∂v/∂t = nu * Laplacian(v)`（nu は動粘性係数）。
 *
 * **Discretization:**
 * Using implicit Euler for stability, we solve:
 *   `(I - nu * Δt * Laplacian) v_new = v_old`
 *
 * The discrete Laplacian on a uniform grid (h=1) is the 4-neighbor stencil:
 *   `Laplacian(v) ≈ left + right + up + down - 4 * center`
 *
 * Rearranging for the Jacobi update with `alpha = 1 / (nu * Δt)`:
 *   `v_new = (left + right + up + down + alpha * center) / (4 + alpha)`
 *
 * When viscosity is very small, alpha becomes very large and the result
 * approaches `center` (almost no diffusion), which is physically correct.
 *
 * **離散化：**
 * 安定性のための陰的オイラー法で解く:
 *   `(I - nu * Δt * Laplacian) v_new = v_old`
 *
 * 均一グリッド（h=1）上の離散ラプラシアンは 4 近傍ステンシル:
 *   `Laplacian(v) ≈ left + right + up + down - 4 * center`
 *
 * `alpha = 1 / (nu * Δt)` としたヤコビ更新式:
 *   `v_new = (left + right + up + down + alpha * center) / (4 + alpha)`
 *
 * 粘性が非常に小さい場合、alpha は非常に大きくなり、結果は
 * `center` に近づく（ほぼ拡散なし）。これが物理的に正しい挙動。
 *
 * Multiple iterations converge toward the true solution.
 * 複数回の反復で真の解に収束する。
 *
 * @param src  Current velocity field. 現在の速度場。
 * @param dst  Output velocity field after one Jacobi step. ヤコビ 1 ステップ後の出力速度場。
 * @param p    Simulation parameters (`deltaTime`, `viscosity`). シミュレーションパラメータ（`deltaTime`, `viscosity`）。
 * @param gid  Thread position. スレッド位置。
 */
kernel void fluidDiffusion(
    texture2d<float, access::read>  src  [[texture(0)]],
    texture2d<float, access::write> dst  [[texture(1)]],
    constant SimParams&             p    [[buffer(0)]],
    uint2                           gid  [[thread_position_in_grid]],
    uint2                           ltid [[thread_position_in_threadgroup]],
    uint2                           lsize [[threads_per_threadgroup]]
) {
    threadgroup float4 tile[18][18];
    int2 size = int2(src.get_width(), src.get_height());
    loadTile4(tile, src, ltid, lsize, gid, size);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (int(gid.x) >= size.x || int(gid.y) >= size.y) return;

    const uint lx = ltid.x + 1, ly = ltid.y + 1;
    float4 center = tile[ly][lx];
    float4 left   = tile[ly][lx - 1];
    float4 right  = tile[ly][lx + 1];
    float4 up     = tile[ly - 1][lx];
    float4 down   = tile[ly + 1][lx];

    float alpha = 1.0 / max(p.viscosity * p.deltaTime, 1e-6);
    float blend = 1.0 / (4.0 + alpha);
    float4 result = blend * (left + right + up + down + center * alpha);
    dst.write(result, gid);
}

// ============================================================================
// Compute: Divergence of velocity field
// ============================================================================

/**
 * @brief  Compute the divergence of the velocity field using central differences.
 *         中心差分で速度場の発散を計算する。
 *
 * **Physics:**
 * Divergence measures how much fluid is "expanding" or "compressing" at a point.
 * For an incompressible fluid, div(v) must be zero everywhere.
 * **物理：**
 * 発散は、ある点で流体がどれだけ「膨張」または「圧縮」しているかを測る。
 * 非圧縮性流体では、div(v) はどこでもゼロでなければならない。
 *
 * **Math (central difference approximation):**
 *   `div(v) = dVx/dx + dVy/dy`
 *   `≈ (V_right.x - V_left.x) / (2*h) + (V_down.y - V_up.y) / (2*h)`
 *
 * With h = 1 (unit grid spacing), this simplifies to:
 *   `div(v) = 0.5 * (V_right.x - V_left.x + V_down.y - V_up.y)`
 *
 * **数学（中心差分近似）：**
 *   `div(v) = dVx/dx + dVy/dy`
 *   `≈ (V_right.x - V_left.x) / (2*h) + (V_down.y - V_up.y) / (2*h)`
 *
 * h = 1（単位グリッド間隔）では以下に簡略化:
 *   `div(v) = 0.5 * (V_right.x - V_left.x + V_down.y - V_up.y)`
 *
 * @param vel  Input velocity field. 入力速度場。
 * @param div  Output divergence field (scalar in .r). 出力発散場（.r にスカラー）。
 * @param gid  Thread position. スレッド位置。
 */
kernel void fluidDivergence(
    texture2d<float, access::read>  vel   [[texture(0)]],
    texture2d<float, access::write> div   [[texture(1)]],
    uint2                           gid   [[thread_position_in_grid]],
    uint2                           ltid  [[thread_position_in_threadgroup]],
    uint2                           lsize [[threads_per_threadgroup]]
) {
    threadgroup float4 tile[18][18];
    int2 size = int2(vel.get_width(), vel.get_height());
    loadTile4(tile, vel, ltid, lsize, gid, size);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (int(gid.x) >= size.x || int(gid.y) >= size.y) return;

    const uint lx = ltid.x + 1, ly = ltid.y + 1;
    float leftVx  = tile[ly][lx - 1].x;
    float rightVx = tile[ly][lx + 1].x;
    float upVy    = tile[ly - 1][lx].y;
    float downVy  = tile[ly + 1][lx].y;

    float d = 0.5 * (rightVx - leftVx + downVy - upVy);
    div.write(float4(d, 0.0, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Pressure solve (Jacobi iteration)
// ============================================================================

/**
 * @brief  One Jacobi iteration for the pressure Poisson equation.
 *         圧力ポアソン方程式のヤコビ反復を 1 回実行する。
 *
 * **Physics:**
 * To enforce incompressibility (div v = 0), we solve for a pressure field p
 * such that: `Laplacian(p) = div(v)`.
 * **物理：**
 * 非圧縮性 (div v = 0) を強制するため、次を満たす圧力場 p を解く:
 *   `Laplacian(p) = div(v)`
 *
 * **Math (Jacobi iteration for Poisson equation):**
 * Rearranging the discrete Laplacian:
 *   `p_left + p_right + p_up + p_down - 4*p_center = div`
 *
 * Solving for the center:
 *   `p_center = 0.25 * (p_left + p_right + p_up + p_down - div)`
 *
 * Each iteration brings the solution closer to the true pressure field.
 *
 * **数学（ポアソン方程式のヤコビ反復）：**
 * 離散ラプラシアンを変形:
 *   `p_left + p_right + p_up + p_down - 4*p_center = div`
 *
 * 中心について解く:
 *   `p_center = 0.25 * (p_left + p_right + p_up + p_down - div)`
 *
 * 反復ごとに真の圧力場に近づく。
 *
 * @param x    Current pressure estimate. 現在の圧力推定値。
 * @param b    Divergence field (right-hand side). 発散場（右辺）。
 * @param out  Updated pressure estimate. 更新された圧力推定値。
 * @param gid  Thread position. スレッド位置。
 */
kernel void fluidPressure(
    texture2d<float, access::read>  x     [[texture(0)]],
    texture2d<float, access::read>  b     [[texture(1)]],
    texture2d<float, access::write> out   [[texture(2)]],
    uint2                           gid   [[thread_position_in_grid]],
    uint2                           ltid  [[thread_position_in_threadgroup]],
    uint2                           lsize [[threads_per_threadgroup]]
) {
    threadgroup float4 tile[18][18];
    int2 size = int2(x.get_width(), x.get_height());
    loadTile4(tile, x, ltid, lsize, gid, size);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (int(gid.x) >= size.x || int(gid.y) >= size.y) return;

    const uint lx = ltid.x + 1, ly = ltid.y + 1;
    float left  = tile[ly][lx - 1].x;
    float right = tile[ly][lx + 1].x;
    float up    = tile[ly - 1][lx].x;
    float down  = tile[ly + 1][lx].x;

    float divergence = b.read(gid).x;
    float pressure = 0.25 * (left + right + up + down - divergence);
    out.write(float4(pressure, 0.0, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Project – subtract pressure gradient from velocity
// ============================================================================

/**
 * @brief  Subtract the pressure gradient from the velocity field to make it divergence-free.
 *         速度場から圧力勾配を減算し、発散なし（非圧縮）にする。
 *
 * **Physics (Helmholtz-Hodge decomposition):**
 * Any vector field v can be decomposed as: `v = v_df + grad(p)`,
 * where v_df is divergence-free (incompressible) and grad(p) is curl-free.
 * By subtracting grad(p) we recover the divergence-free part: `v_df = v - grad(p)`.
 *
 * This is the final step that enforces the incompressibility constraint div(v) = 0,
 * which is the fundamental property of an incompressible fluid.
 *
 * **物理（Helmholtz-Hodge 分解）：**
 * 任意のベクトル場 v は次のように分解できる: `v = v_df + grad(p)`
 * ここで v_df は発散なし（非圧縮）、grad(p) は渦なし。
 * grad(p) を減算して発散なし成分を得る: `v_df = v - grad(p)`。
 *
 * これは非圧縮性制約 div(v) = 0 を強制する最終ステップであり、
 * 非圧縮性流体の基本的な性質である。
 *
 * **Math (central-difference gradient):**
 *   `grad(p).x = (p_right - p_left) / (2*h)`
 *   `grad(p).y = (p_down  - p_up  ) / (2*h)`
 * With h = 1: multiply by 0.5.
 *
 * **数学（中心差分勾配）：**
 *   `grad(p).x = (p_right - p_left) / (2*h)`
 *   `grad(p).y = (p_down  - p_up  ) / (2*h)`
 * h = 1 では 0.5 を掛ける。
 *
 * @param vel       Current velocity field. 現在の速度場。
 * @param pressure  Solved pressure field. 求解された圧力場。
 * @param out       Divergence-free velocity field. 発散なし速度場。
 * @param gid       Thread position. スレッド位置。
 */
kernel void fluidProject(
    texture2d<float, access::read>  vel      [[texture(0)]],
    texture2d<float, access::read>  pressure [[texture(1)]],
    texture2d<float, access::write> out      [[texture(2)]],
    uint2                           gid      [[thread_position_in_grid]],
    uint2                           ltid     [[thread_position_in_threadgroup]],
    uint2                           lsize    [[threads_per_threadgroup]]
) {
    threadgroup float4 pTile[18][18];
    int2 size = int2(vel.get_width(), vel.get_height());
    loadTile4(pTile, pressure, ltid, lsize, gid, size);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    if (int(gid.x) >= size.x || int(gid.y) >= size.y) return;

    const uint lx = ltid.x + 1, ly = ltid.y + 1;
    float leftP  = pTile[ly][lx - 1].x;
    float rightP = pTile[ly][lx + 1].x;
    float upP    = pTile[ly - 1][lx].x;
    float downP  = pTile[ly + 1][lx].x;

    float2 grad = float2(0.5 * (rightP - leftP), 0.5 * (downP - upP));
    float2 v = vel.read(gid).xy - grad;
    out.write(float4(v, 0.0, 1.0), gid);
}

// ============================================================================
// Compute: Advect ink density using velocity field
// ============================================================================

/**
 * @brief  Advect the scalar ink density field using the (now divergence-free) velocity.
 *         （発散なしになった）速度を使って、スカラーインク密度場を移流する。
 *
 * Same Semi-Lagrangian algorithm as `fluidAdvect`, but applied to a passive
 * scalar quantity (ink) rather than the velocity itself.
 * `fluidAdvect` と同じ Semi-Lagrangian アルゴリズムだが、速度自体ではなく
 * パッシブスカラー量（インク）に適用する。
 *
 * "Passive scalar" means the ink is carried by the flow but does not affect it.
 * 「パッシブスカラー」とは、インクは流れに運ばれるが流れ自体には影響しないことを意味する。
 *
 * @param vel   Velocity field (read-only, for tracing). 速度場（読み取り専用、追跡用）。
 * @param src   Current ink density (sampled with bilinear filtering). 現在のインク密度（バイリニアフィルタリングでサンプリング）。
 * @param dst   Output advected ink density. 出力：移流後のインク密度。
 * @param samp  Linear sampler. リニアサンプラー。
 * @param p     Simulation parameters (`deltaTime`). シミュレーションパラメータ（`deltaTime`）。
 * @param gid   Thread position. スレッド位置。
 */
kernel void fluidAdvectInk(
    texture2d<float, access::read>  vel  [[texture(0)]],
    texture2d<half, access::sample> src  [[texture(1)]],
    texture2d<float, access::write> dst  [[texture(2)]],
    sampler                         samp [[sampler(0)]],
    constant SimParams&             p    [[buffer(0)]],
    uint2                           gid  [[thread_position_in_grid]]
) {
    uint w = src.get_width();
    uint h = src.get_height();

    float2 v = vel.read(gid).xy;
    float2 prevPos = float2(gid) - p.deltaTime * v;
    float2 clamped = clamp(prevPos, float2(-0.5), float2(float(w), float(h)) - 0.5);
    float2 uv = (clamped + 0.5) / float2(float(w), float(h));
    float4 sampled = float4(src.sample(samp, uv));
    dst.write(sampled, gid);
}

// ============================================================================
// Render: Fullscreen triangle
// ============================================================================

/**
 * @brief  Vertex-to-fragment interpolated data for fullscreen rendering.
 *         フルスクリーンレンダリング用の頂点→フラグメント補間データ。
 */
struct VSOut {
    float4 position [[position]]; ///< Clip-space position. クリップ空間位置。
    float2 uv;                    ///< Texture coordinate [0,1]. テクスチャ座標 [0,1]。
};

/**
 * @brief  Fullscreen triangle vertex shader (3-vertex oversized triangle trick).
 *         フルスクリーン三角形頂点シェーダ（3 頂点の巨大三角形トリック）。
 *
 * Instead of drawing a quad with 4 vertices (or 6 with two triangles),
 * a single oversized triangle with vertices at (-1,-1), (3,-1), (-1,3)
 * covers the entire [-1,1] clip space. The GPU's rasterizer clips it
 * to the viewport automatically. No vertex buffer is needed.
 * 4 頂点のクアッド（または 2 三角形 6 頂点）の代わりに、
 * (-1,-1), (3,-1), (-1,3) の頂点を持つ巨大三角形 1 つで
 * [-1,1] のクリップ空間全体をカバーする。GPU のラスタライザが
 * 自動的にビューポートにクリップする。頂点バッファ不要。
 *
 * UV coordinates are set so that (0,0) is bottom-left and (1,1) is top-right
 * after clipping.
 * UV 座標はクリップ後に (0,0) が左下、(1,1) が右上となるように設定。
 *
 * @param vid  Vertex ID (0, 1, or 2). 頂点 ID（0, 1, 2）。
 * @return     Position and UV for the rasterizer. ラスタライザ用の位置と UV。
 */
vertex VSOut fluidFullscreenVS(uint vid [[vertex_id]]) {
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

// ============================================================================
// Fragment: Ink visualization
// ============================================================================

/**
 * @brief  Visualize the ink density field with a warm color tone.
 *         インク密度場を暖色トーンで可視化する。
 *
 * Maps scalar density d to color: `(d, 0.8d, 0.5d)`, producing an
 * amber/orange gradient from black (no ink) to warm white (saturated ink).
 * スカラー密度 d をカラーにマッピング: `(d, 0.8d, 0.5d)`。
 * 黒（インクなし）から暖かい白（飽和インク）へのアンバー/オレンジのグラデーション。
 *
 * @param in    Interpolated vertex output (UV coordinates). 補間された頂点出力（UV 座標）。
 * @param tex   Ink density texture. インク密度テクスチャ。
 * @param samp  Linear sampler. リニアサンプラー。
 * @return      RGBA fragment color. RGBA フラグメントカラー。
 */
fragment half4 fluidInkFS(
    VSOut                          in   [[stage_in]],
    texture2d<half, access::sample> tex [[texture(0)]],
    sampler                        samp [[sampler(0)]]
) {
    half d = tex.sample(samp, in.uv).x;
    return half4(d, d * 0.8h, d * 0.5h, 1.0h);
}

// ============================================================================
// Fragment: Velocity visualization
// ============================================================================

/**
 * @brief  Visualize the velocity field as a color map.
 *         速度場をカラーマップで可視化する。
 *
 * Mapping: `R = (vx + 1) / 2`, `G = (vy + 1) / 2`, `B = 0.4 * |v|`.
 * Velocity components are shifted from [-1,1] to [0,1] for display.
 * Blue encodes the overall speed (magnitude).
 * マッピング: `R = (vx + 1) / 2`, `G = (vy + 1) / 2`, `B = 0.4 * |v|`。
 * 速度成分は [-1,1] から [0,1] にシフトして表示。
 * 青は全体の速さ（大きさ）を表す。
 *
 * @param in    Interpolated vertex output. 補間された頂点出力。
 * @param tex   Velocity texture. 速度テクスチャ。
 * @param samp  Linear sampler. リニアサンプラー。
 * @return      RGBA fragment color. RGBA フラグメントカラー。
 */
fragment half4 fluidVelocityFS(
    VSOut                          in   [[stage_in]],
    texture2d<half, access::sample> tex [[texture(0)]],
    sampler                        samp [[sampler(0)]]
) {
    half2 vel = tex.sample(samp, in.uv).xy;
    half mag = length(vel);
    return half4((vel.x + 1.0h) * 0.5h, (vel.y + 1.0h) * 0.5h, mag * 0.4h, 1.0h);
}

// ============================================================================
// Fragment: Image distortion via ink density gradient (aspect fit / fill)
// ============================================================================

/// Scaling mode resolved at PSO creation time.
/// true = aspect fill (center crop), false = aspect fit (letterbox).
constant bool kUseAspectFill [[function_constant(0)]];

/**
 * @brief  Parameters for the image-distortion fragment shader.
 *         画像歪みフラグメントシェーダ用パラメータ。
 */
struct ImageParams {
    float pixelStep;   ///< One pixel in UV space (1/gridWidth). UV 空間での 1 ピクセル幅。
    float imageAspect; ///< Background image width / height. 背景画像の幅/高さ比。
};

/**
 * @brief  Distort a background image using the ink density gradient for a fluid displacement effect.
 *         インク密度の勾配を使って背景画像を歪め、流体ディスプレースメントエフェクトを生成する。
 *
 * **Algorithm:**
 *   1. **Finite-difference gradient:** Sample ink density at 4 neighboring pixels
 *      (left, right, up, down) and compute the gradient:
 *        `grad.x = ink(right) - ink(left)`
 *        `grad.y = ink(up)    - ink(down)`
 *      This estimates how rapidly ink density changes in each direction.
 *
 *   2. **UV distortion:** Offset the texture coordinate by the gradient scaled
 *      by a strength factor: `distorted = uv + grad * strength`.
 *      The Y component is negated because the gradient's Y direction is
 *      opposite to the UV's Y direction.
 *
 *   3. **Aspect mapping:** The simulation grid is square, but the background
 *      image may not be. The `kUseAspectFill` function constant (fixed at PSO
 *      creation time) selects:
 *      - **Fit (letterbox):** entire image inside the square; bars may be black.
 *        - aspect > 1: letterbox top/bottom.
 *        - aspect <= 1: letterbox left/right.
 *      - **Fill (center crop):** image covers the square; excess is clipped.
 *        - aspect > 1: crop left/right.
 *        - aspect <= 1: crop top/bottom.
 *
 *   4. **Y-flip:** Metal textures have origin at top-left, but the simulation
 *      grid has origin at bottom-left, so we flip `bgUV.y = 1.0 - bgUV.y`.
 *
 *   5. **Bounds check:** For fit, pixels outside [0,1] (letterbox bars) are black.
 *      For fill, kept for numerical edge cases.
 *
 * **アルゴリズム：**
 *   1. **有限差分勾配：** 4 近傍ピクセル（左右上下）のインク密度をサンプリングし勾配を計算:
 *        `grad.x = ink(right) - ink(left)`
 *        `grad.y = ink(up)    - ink(down)`
 *      各方向のインク密度の変化率を推定。
 *
 *   2. **UV 歪み：** テクスチャ座標を勾配にストレングス係数を掛けてオフセット:
 *      `distorted = uv + grad * strength`。
 *      勾配の Y 方向と UV の Y 方向が逆なので Y 成分は符号を反転。
 *
 *   3. **アスペクトマッピング：** シミュレーションは正方形だが背景画像はそうとは限らない。
 *      `kUseAspectFill` function constant（PSO 構築時に解決）で次を選択：
 *      - **フィット（レターボックス）：** 画像全体を正方形内に収める。帯は黒。
 *        - aspect > 1: 上下レターボックス。
 *        - aspect <= 1: 左右レターボックス。
 *      - **フィル（中央クロップ）：** 正方形を覆う。はみ出しは切り捨て。
 *        - aspect > 1: 左右クロップ。
 *        - aspect <= 1: 上下クロップ。
 *
 *   4. **Y 反転：** Metal テクスチャの原点は左上だが、シミュレーショングリッドの
 *      原点は左下なので `bgUV.y = 1.0 - bgUV.y` で反転。
 *
 *   5. **範囲チェック：** フィットでは [0,1] 外（レターボックス帯）を黒。フィルでは数値誤差用。
 *
 * @param in      Interpolated vertex output (UV). 補間された頂点出力（UV）。
 * @param inkTex  Ink density texture (for gradient computation). インク密度テクスチャ（勾配計算用）。
 * @param bgTex   Background image texture. 背景画像テクスチャ。
 * @param samp    Linear sampler. リニアサンプラー。
 * @param params  Image display parameters. 画像表示パラメータ。
 * @return        RGBA fragment color. RGBA フラグメントカラー。
 */
fragment half4 fluidImageFS(
    VSOut                           in      [[stage_in]],
    texture2d<half, access::sample> inkTex  [[texture(0)]],
    texture2d<float, access::sample> bgTex  [[texture(1)]],
    sampler                         samp    [[sampler(0)]],
    constant ImageParams&           params  [[buffer(0)]]
) {
    float ps = params.pixelStep;
    half left  = inkTex.sample(samp, float2(in.uv.x - ps, in.uv.y)).x;
    half right = inkTex.sample(samp, float2(in.uv.x + ps, in.uv.y)).x;
    half up    = inkTex.sample(samp, float2(in.uv.x, in.uv.y + ps)).x;
    half down  = inkTex.sample(samp, float2(in.uv.x, in.uv.y - ps)).x;

    float2 grad = float2(float(right - left), float(up - down));
    float strength = 0.8;
    float2 distorted = in.uv + grad * float2(strength, -strength);

    float aspect = params.imageAspect;
    float2 bgUV;
    if (kUseAspectFill) {
        if (aspect > 1.0) {
            bgUV = float2(0.5 + (distorted.x - 0.5) / aspect, distorted.y);
        } else {
            bgUV = float2(distorted.x, 0.5 + (distorted.y - 0.5) * aspect);
        }
    } else {
        if (aspect > 1.0) {
            float h = 1.0 / aspect;
            float off = (1.0 - h) * 0.5;
            bgUV = float2(distorted.x, (distorted.y - off) / h);
        } else {
            float w = aspect;
            float off = (1.0 - w) * 0.5;
            bgUV = float2((distorted.x - off) / w, distorted.y);
        }
    }
    bgUV.y = 1.0 - bgUV.y;

    if (bgUV.x < 0.0 || bgUV.x > 1.0 || bgUV.y < 0.0 || bgUV.y > 1.0) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }

    half4 color = half4(bgTex.sample(samp, bgUV));
    return half4(color.rgb, 1.0h);
}
