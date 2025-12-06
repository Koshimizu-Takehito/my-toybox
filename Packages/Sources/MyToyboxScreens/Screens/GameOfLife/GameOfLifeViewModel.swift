import Foundation
import Observation

// MARK: - GameOfLifeViewModel

/// Conway のライフゲーム表示・操作に関する状態を管理する ViewModel。
@MainActor
@Observable
final class GameOfLifeViewModel {
    // MARK: Current View State

    /// 拡大率（1.0 を既定とする）。
    var scale: CGFloat = 1.0

    /// 正規化空間上の表示中心位置。(-0.5 ... 0.5) を想定。
    var location: CGPoint = .zero

    /// 追加オフセット（必要に応じて利用）。
    var offset: CGPoint = .zero

    /// 自動ステップ実行フラグ。
    var isRunning: Bool = false

    /// 自動ステップの間隔（ミリ秒）。
    var cycleIntervalMS: Double = 30.0

    /// 盤面の一辺セル数。
    /// 値変更時は `onSizeChanged` が呼ばれる。
    var size: Int = 256 {
        didSet {
            onSizeChanged?(size)
        }
    }

    // MARK: Gesture Anchors

    /// ズーム操作の継続点（直前の拡大率）。
    @ObservationIgnored var lastScale: CGFloat = 1.0

    /// パン操作の継続点（直前の座標）。
    @ObservationIgnored var lastLocation: CGPoint = .zero

    // MARK: Metrics

    /// 実行済みステップ数（描画用メトリクス）。
    private(set) var numberOfCycles: Int = 0

    // MARK: Renderer Hooks

    /// サイズ変更時に呼ばれるフック。
    @ObservationIgnored var onSizeChanged: ((Int) -> Void)?

    /// ステップコミット後に呼ばれるフック。
    @ObservationIgnored var onStepCommitted: (() -> Void)?

    // MARK: Lifecycle

    /// 1ステップ進行が確定したことを通知する。
    func didCommitStep() {
        numberOfCycles += 1
        onStepCommitted?()
    }

    /// 表示系メトリクスをリセットする。
    func resetStats() {
        numberOfCycles = 0
    }

    // MARK: Zoom Controls

    /// 既定表示（1x・中央）へリセットする。
    func resetView() {
        scale = 1.0
        lastScale = 1.0
        location = .zero
        lastLocation = .zero
        offset = .zero
    }

    /// 段階的に拡大する（継続点も更新）。
    func incrementScale() {
        let new = max(1.0, scale * 1.5)
        scale = new
        lastScale = new
        clampLocation()
    }

    /// 段階的に縮小する（継続点も更新、1x なら中央へ）。
    func decrementScale() {
        let new = max(1.0, scale / 1.5)
        scale = new
        lastScale = new
        if new == 1.0 {
            location = .zero
            lastLocation = .zero
            offset = .zero
        } else {
            clampLocation()
        }
    }

    /// 現在の `scale` に基づいて `location` をクランプする。
    func clampLocation() {
        let s = max(1.0, scale)
        let v = 0.5 - (1.0 / (2.0 * s)) // 表示領域の半径（正規化）
        location.x = CGFloat(max(-v, min(v, Double(location.x))))
        location.y = CGFloat(max(-v, min(v, Double(location.y))))
    }
}
