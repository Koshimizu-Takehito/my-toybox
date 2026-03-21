import SwiftUI

// MARK: - StableFluidScreen

/// Main screen for the interactive stable fluid simulation.
/// インタラクティブな安定流体シミュレーションのメイン画面。
///
/// ## Attribution
/// The stable fluid simulation algorithm is based on
/// Jos Stam, *"Stable Fluids,"* SIGGRAPH 1999.
///
/// This implementation is inspired by the WebGPU example in
/// [TypeGPU](https://github.com/software-mansion/TypeGPU)
/// (`apps/typegpu-docs/src/examples/simulation/stable-fluid/`).
/// TypeGPU is **© 2025 Software Mansion** and distributed under the **MIT License**.
///
/// The user drags on the Metal view to inject ink and apply forces;
/// the simulation responds in real time. Controls at the bottom
/// allow switching display modes and tuning simulation parameters.
/// ユーザーが Metal ビュー上をドラッグしてインクを注入し力を加え、
/// シミュレーションがリアルタイムで応答する。下部のコントロールで
/// 表示モードの切り替えやシミュレーションパラメータの調整が可能。
@Metadata(title: "Stable Fluid", description: "安定流体シミュレーション", tags: [.animation, .metal])
struct StableFluidScreen: View {
    @State private var viewModel = StableFluidViewModel()

    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                MetalStableFluidView(viewModel: viewModel)
                    .gesture(brushGesture(size: geometry.size))
            }
            .scaledToFit()

            controls
                .padding(.horizontal)
        }
        .tint(.blue)
    }

    // MARK: Brush Gesture

    /// Build a drag gesture that converts screen-space touch coordinates
    /// into simulation grid coordinates and updates the brush state.
    /// スクリーン空間のタッチ座標をシミュレーショングリッド座標に変換し、
    /// ブラシ状態を更新するドラッグジェスチャを構築する。
    ///
    /// **Coordinate transform:**
    /// - Screen: origin at top-left, Y increases downward (UIKit convention).
    /// - Grid: origin at bottom-left, Y increases upward (math convention).
    /// - The Y axis is flipped via `1.0 - (y / height)`.
    /// - `delta` is the per-frame displacement in grid cells, which becomes
    ///   the force direction in the `fluidBrush` compute kernel.
    ///
    /// **座標変換：**
    /// - スクリーン：左上が原点、Y は下向きに増加（UIKit 規約）。
    /// - グリッド：左下が原点、Y は上向きに増加（数学的規約）。
    /// - Y 軸は `1.0 - (y / height)` で反転される。
    /// - `delta` はグリッドセル単位のフレーム間変位で、
    ///   `fluidBrush` コンピュートカーネルの力の方向になる。
    ///
    /// - Parameter size: The view's size in points (from GeometryReader).
    ///                   ビューのポイント単位のサイズ（GeometryReader から取得）。
    private func brushGesture(size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let gridN = Float(viewModel.gridSize)
                let x = Float(value.location.x / size.width) * gridN
                let y = Float(1.0 - value.location.y / size.height) * gridN
                let newPos = SIMD2<Int32>(Int32(x), Int32(y))

                if let lastLoc = viewModel.lastDragLocation {
                    let lastX = Float(lastLoc.x / size.width) * gridN
                    let lastY = Float(1.0 - lastLoc.y / size.height) * gridN
                    viewModel.brush.delta = SIMD2<Float>(x - lastX, y - lastY)
                } else {
                    viewModel.brush.delta = .zero
                }

                viewModel.brush.pos = newPos
                viewModel.brush.isDown = true
                viewModel.lastDragLocation = value.location
            }
            .onEnded { _ in
                viewModel.brush.isDown = false
                viewModel.brush.delta = .zero
                viewModel.lastDragLocation = nil
            }
    }

    // MARK: Controls

    /// Control panel for display mode, simulation parameters, and playback.
    /// 表示モード、シミュレーションパラメータ、再生制御の操作パネル。
    @ViewBuilder
    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Display")
                    .font(.subheadline.weight(.semibold))
                Picker("Display", selection: $viewModel.displayMode) {
                    ForEach(StableFluidDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            LabeledContent("Time Step: \(viewModel.deltaTime, specifier: "%.2f")") {
                Slider(value: $viewModel.deltaTime, in: 0.05 ... 2.0, step: 0.01)
            }

            LabeledContent("Viscosity: \(viewModel.viscosity, specifier: "%.6f")") {
                Slider(value: $viewModel.viscosity, in: 0 ... 0.01, step: 0.000001)
            }

            HStack(spacing: 16) {
                Button {
                    viewModel.paused.toggle()
                } label: {
                    Label(
                        viewModel.paused ? "Resume" : "Pause",
                        systemImage: viewModel.paused ? "play.fill" : "pause.fill"
                    )
                }

                Button {
                    viewModel.paused = false
                    viewModel.notifyGridSizeChanged()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.body.weight(.semibold))
        }
        .font(.subheadline.monospacedDigit())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StableFluidScreen()
            .navigationTitle("Stable Fluid")
            .toolbarTitleDisplayMode(.inlineLarge)
    }
    .colorScheme(.dark)
}
