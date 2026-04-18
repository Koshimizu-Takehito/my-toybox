import Foundation
import Observation

// MARK: - StableFluidDisplayMode

/// Visualization mode for the stable fluid simulation output.
/// 安定流体シミュレーションの出力を可視化するモード。
enum StableFluidDisplayMode: String, CaseIterable {
    /// Distort a background image using the ink density gradient (displacement effect).
    /// インク密度の勾配を使い、背景画像を歪ませて表示する（ディスプレースメントエフェクト）。
    case image

    /// Render the scalar ink density field as a warm-toned color map.
    /// スカラーのインク密度場を暖色系のカラーマップで描画する。
    case ink

    /// Render the 2D velocity field as color (x -> red, y -> green, magnitude -> blue).
    /// 2D 速度場をカラーで描画する（x → 赤, y → 緑, 大きさ → 青）。
    case velocity
}

// MARK: - StableFluidImageContentMode

/// How the background image is mapped onto the square simulation viewport (image display mode only).
/// 背景画像を正方形のシミュレーション表示領域にどうマップするか（画像表示モード時のみ）。
enum StableFluidImageContentMode: String, CaseIterable {
    /// Letterbox: entire image visible inside the square.
    /// レターボックス：画像全体を正方形内に収める。
    case aspectFit

    /// Center crop: image covers the square; excess is clipped.
    /// 中央クロップ：正方形を隙間なく覆い、はみ出しを切り捨てる。
    case aspectFill

}

// MARK: - BrushState

/// Snapshot of the current touch/drag state used to drive the fluid brush.
/// 流体ブラシを駆動するための、現在のタッチ/ドラッグ状態のスナップショット。
struct BrushState {
    /// Current brush position in simulation grid coordinates (integer cell indices).
    /// シミュレーショングリッド座標でのブラシ位置（整数セルインデックス）。
    var pos: SIMD2<Int32> = .zero

    /// Frame-to-frame movement delta in grid cells, used as the force direction.
    /// グリッドセル単位のフレーム間移動差分。力の方向として使用される。
    var delta: SIMD2<Float> = .zero

    /// Whether the user is currently touching/dragging.
    /// ユーザーが現在タッチ/ドラッグ中かどうか。
    var isDown: Bool = false
}

// MARK: - StableFluidViewModel

/// ViewModel for the Jos Stam "Stable Fluids" (1999) simulation.
/// Jos Stam の「Stable Fluids」（1999）シミュレーションの ViewModel。
///
/// This simulation solves a simplified 2D incompressible Navier-Stokes equation
/// on a uniform grid using operator splitting:
/// このシミュレーションは、演算子分割を用いて均一グリッド上の
/// 簡略化された 2D 非圧縮 Navier-Stokes 方程式を解く：
///
///   1. **External forces** – add user-driven forces (brush input)
///   2. **Advection** – Semi-Lagrangian transport (unconditionally stable)
///   3. **Diffusion** – viscous dissipation via Jacobi iteration
///   4. **Pressure projection** – enforce incompressibility (div v = 0)
///      via Helmholtz-Hodge decomposition
///
/// Each step runs as a Metal compute shader on the GPU every frame.
/// 各ステップは毎フレーム Metal コンピュートシェーダとして GPU 上で実行される。
///
/// ## Attribution
/// The stable fluid simulation algorithm is based on
/// Jos Stam, *"Stable Fluids,"* SIGGRAPH 1999.
///
/// This implementation is inspired by the WebGPU example in
/// [TypeGPU](https://github.com/software-mansion/TypeGPU)
/// (`apps/typegpu-docs/src/examples/simulation/stable-fluid/`).
/// TypeGPU is **© 2025 Software Mansion** and distributed under the **MIT License**.
@MainActor
@Observable
final class StableFluidViewModel {
    // MARK: Simulation Parameters

    /// Discrete time step (Δt, dimensionless) for Euler integration and advection.
    /// Larger values produce more dramatic fluid motion per frame.
    /// オイラー積分と移流の離散時間刻み幅（Δt、無次元）。
    /// 値が大きいほど、フレームあたりの流体運動が大きくなる。
    var deltaTime: Float = 1.0

    /// Kinematic viscosity coefficient (nu, dimensionless) for the diffusion step.
    /// Higher values make the fluid thicker and slower (like honey);
    /// lower values give a thinner, more turbulent fluid (like water).
    /// 拡散ステップの動粘性係数（nu、無次元）。
    /// 値が大きいと流体が粘稠で遅くなり（蜂蜜のように）、
    /// 小さいと薄く乱流的になる（水のように）。
    var viscosity: Float = 0.0001

    /// Number of Jacobi iterations for both diffusion and pressure solves.
    /// More iterations improve accuracy but cost more GPU time.
    /// 拡散および圧力求解両方のヤコビ反復回数。
    /// 反復を増やすと精度が向上するが、GPU 処理時間が増加する。
    var jacobiIterations: Int = 10

    /// Current visualization mode (image distortion, ink density, or velocity field).
    /// 現在の可視化モード（画像歪み、インク密度、または速度場）。
    var displayMode: StableFluidDisplayMode = .image

    /// Aspect fit vs fill for the image distortion mode (`displayMode == .image`).
    /// 画像歪みモード（`displayMode == .image`）のアスペクトフィット / フィル。
    var imageContentMode: StableFluidImageContentMode = .aspectFit

    /// Whether the simulation is paused.
    /// シミュレーションが一時停止中かどうか。
    var paused: Bool = false

    /// Number of cells along each axis of the square simulation grid.
    /// 正方形シミュレーショングリッドの各軸のセル数。
    var gridSize: Int = 256

    // MARK: Brush

    /// Current brush input state, updated by the SwiftUI drag gesture.
    /// SwiftUI のドラッグジェスチャで更新される、現在のブラシ入力状態。
    var brush = BrushState()

    /// Previous drag location in screen points, used to compute `brush.delta`.
    /// `brush.delta` の計算に使う、スクリーンポイント単位の前回ドラッグ位置。
    @ObservationIgnored var lastDragLocation: CGPoint?

    // MARK: Callbacks

    /// Hook called by the Coordinator when the grid size changes to reallocate textures.
    /// グリッドサイズ変更時にテクスチャを再確保するため Coordinator が呼び出すフック。
    @ObservationIgnored var onGridSizeChanged: ((Int) -> Void)?

    init(imageContentMode: StableFluidImageContentMode = .aspectFit) {
        self.imageContentMode = imageContentMode
    }

    /// Trigger a grid-size change notification (used by the Reset button).
    /// グリッドサイズ変更通知を発火する（リセットボタンで使用）。
    func notifyGridSizeChanged() {
        onGridSizeChanged?(gridSize)
    }
}
