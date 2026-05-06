import Combine
import Foundation
import MyToyboxCore

// MARK: - MazeGenerator

/// An actor that generates a maze using a depth-first search (DFS) based approach.
/// 深さ優先探索 (DFS) ベースのアルゴリズムを用いて迷路を生成する。
///
/// This actor provides an async stream of snapshots (`MazeGenerator.Snapshot`) so that observers
/// can track the maze's state and generation progress in real time.
/// スナップショット（`MazeGenerator.Snapshot`）を非同期ストリームで提供し、外部がリアルタイムで進捗を追跡できるようにします。
actor MazeGenerator {
    /// The grid width (must be an odd number).
    /// 迷路の幅（必ず奇数）。
    private let width: Int

    /// The grid height (must be an odd number).
    /// 迷路の高さ（必ず奇数）。
    private let height: Int

    /// A published snapshot containing the current maze grid and its generation state.
    /// 現在の迷路の状態と生成状況を保持するスナップショット（Published）。
    @Published private(set) var snapshot: Snapshot

    /// An async stream of snapshots providing real-time maze updates.
    /// 迷路の変化をリアルタイムで取得するためのスナップショットストリームです。
    var snapshots: AsyncStream<Snapshot> {
        AsyncStream { continuation in
            Task {
                for await value in $snapshot.values {
                    continuation.yield(value)
                }
            }
        }
    }

    /// Initializes the maze actor with the specified width and height (both odd).
    /// 指定した幅と高さ（ともに奇数）で MazeGenerator actor を初期化します。
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self._snapshot = Published(initialValue: Snapshot(width: width, height: height))
    }

    /// Generates the maze using a DFS-based random walk and backtracking method.
    /// 深さ優先探索(DFS)ベースのランダムウォークとバックトラッキングを用いて迷路を生成します。
    ///
    /// Steps:
    /// 1. Reset the grid to all walls (false).
    /// 2. Pick a random starting cell (odd indices).
    /// 3. Move two cells at a time, breaking the wall in between.
    ///    - Even indices are walls, odd indices are path candidates.
    ///      Moving from odd to odd inevitably crosses an even index (a wall),
    ///      which is turned into a path (true), ensuring corridors of width 1.
    /// 4. Call `Task.yield()` after carving each path so the UI can refresh.
    /// 5. Backtrack if no valid move remains.
    /// 6. Set `snapshot.isGenerating = false` upon completion.
    ///
    /// ----
    ///
    /// 処理の流れ:
    /// 1. グリッドをすべて壁(false)に初期化
    /// 2. 奇数インデックスのセルをランダムな開始地点にする
    /// 3. 2マスずつ移動し、間の偶数インデックスを通路(true)に書き換える
    ///    - 偶数インデックスを壁、奇数インデックスを通路候補とすることで、
    ///      奇数→奇数に移動時は必ず間の偶数座標（壁）を壊し、幅1の道を確保する
    /// 4. 各通路を掘るたびに `Task.yield()` を呼び出し、UI更新を許可
    /// 5. 移動先がなくなったらスタックを戻してバックトラッキング
    /// 6. 全部掘り終えたら `snapshot.isGenerating = false` を設定し、生成終了を通知
    func generate() async {
        // Reset the grid to all walls (false).
        // グリッドを壁(false)にリセット。
        snapshot = Snapshot(width: width, height: height)
        await Task.yield()

        // Pick a random starting cell (odd indices).
        // ランダムな開始地点 (奇数インデックス) を選択。
        let start = SIMD2(
            (Int.random(in: 0 ..< (width / 2)) * 2) + 1,
            (Int.random(in: 0 ..< (height / 2)) * 2) + 1
        )

        var stack = [SIMD2<Int>]()
        stack.append(start)

        // Directions for moving two cells at a time (up, down, left, right).
        // 上下左右に2マスずつ移動する方向の定義。
        let directions: [SIMD2] = [
            .init(0, 2), .init(2, 0),
            .init(0, -2), .init(-2, 0),
        ]

        // Perform random walk until there are no valid moves left.
        // 移動先がなくなるまでランダムウォークを実行。
        while !stack.isEmpty {
            let current = stack.last!
            var moved = false
            for direction in directions.shuffled() {
                let next = current + direction
                if isValid(next) {
                    // Between current and next is a "wall" cell, so open that and the next cell.
                    // current と next の間にある壁を壊し、next を通路として開ける。
                    snapshot.grid[current + (direction / 2)] = true
                    await Task.yield()
                    snapshot.grid[current + direction] = true
                    await Task.yield()
                    stack.append(next)
                    moved = true
                    break
                }
            }
            if !moved {
                // If no move is possible, backtrack by removing the last cell in the stack.
                // 進める方向がなければ、スタックの最後のセルを取り除いてバックトラッキング。
                stack.removeLast()
            }
        }
        // Mark generation as finished.
        // 生成が完了したことを示す。
        snapshot.finish()
        await Task.yield()
    }

    /// Checks if a cell is within the maze boundaries and has not been carved (false).
    /// セルが迷路の範囲内にあり、まだ通路として掘られていない(false)かどうかを確認します。
    private func isValid(_ cell: SIMD2<Int>) -> Bool {
        if cell.x > 0, cell.x < width - 1, cell.y > 0, cell.y < height - 1 {
            return !snapshot.grid[cell]
        }
        return false
    }
}

// MARK: MazeGenerator.Snapshot

nonisolated extension MazeGenerator {
    /// Represents the current maze state, including its grid and whether it's still generating.
    /// 迷路の現在の状態を表し、グリッドと生成中かどうかの情報を含みます。
    struct Snapshot {
        /// Indicates if the maze generation is in progress.
        /// 迷路の生成が続行中かどうか。
        var isGenerating = true

        /// A 2D array representing which cells are open (true) or walls (false).
        /// 各セルが通路(true)か壁(false)かを示す 2 次元配列。
        var grid: [[Bool]]
    }
}

nonisolated extension MazeGenerator.Snapshot {
    /// Initializes a snapshot with the specified grid dimensions, all cells set to false.
    /// 指定したサイズのグリッドを全て壁(false)として初期化します。
    init(width: Int, height: Int) {
        self.init(grid: .init(repeating: .init(repeating: false, count: width), count: height))
    }

    /// Marks the snapshot as finished (no longer generating).
    /// スナップショットを生成完了（生成中ではない）とマークします。
    nonisolated mutating func finish() {
        isGenerating = false
    }
}

// MARK: - SIMD2 Extension

private nonisolated extension SIMD2<Int> {
    /// Adds two SIMD2<Int> values.
    /// 2 つの SIMD2<Int> 値を加算します。
    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        SIMD2(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    /// Divides a SIMD2<Int> value by an integer.
    /// SIMD2<Int> の値を整数で除算します。
    static func / (_ lhs: Self, _ rhs: Int) -> Self {
        SIMD2(lhs.x / rhs, lhs.y / rhs)
    }
}

// MARK: - Array Extension

private nonisolated extension [[Bool]] {
    /// Accesses a 2D Boolean array using a SIMD2<Int> coordinate.
    /// SIMD2<Int> 座標を使用して 2 次元ブール配列にアクセスします。
    subscript(_ p: SIMD2<Int>) -> Bool {
        get { self[p.y][p.x] }
        set { self[p.y][p.x] = newValue }
    }
}
