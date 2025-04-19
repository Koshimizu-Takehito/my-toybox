import Foundation
import Observation

/// `MazeTile` は迷路内に存在するさまざまなタイルの種類を表す
enum MazeTile {
    /// 迷路の開始地点
    case start
    /// 通路
    case path
    /// 壁
    case wall
    /// ゴール地点
    case goal
}

// MARK: - MazeGeneratorViewModel (ViewModel)

/// A view model responsible for managing the maze generation and holding the current grid state.
/// 迷路の生成を管理し、現在の迷路の状態を保持するための ViewModel です。
///
/// This class subscribes to the `MazeGenerator` actor's snapshots to update `grid` and `isGenerating` in real time.
/// `MazeGenerator` actor のスナップショットを購読し、`grid` と `isGenerating` をリアルタイムで更新します。
@MainActor
@Observable
final class MazeGeneratorViewModel {
    private(set) var tiles = [[MazeTile]]()

    /// Indicates whether the maze is currently generating (true) or finished (false).
    /// 迷路の生成中 (true) か、完了 (false) かを示します。
    private(set) var isGenerating = true

    /// The actor that handles maze generation logic.
    /// 迷路生成ロジックを扱う actor。
    private let mazeModel: MazeGenerator

    /// The Task responsible for subscribing to the maze's snapshots and updating the ViewModel properties.
    /// 迷路のスナップショットを購読し、ViewModel のプロパティを更新するタスクです。
    ///
    /// Whenever a new task is assigned, the previous one is cancelled automatically.
    /// 新しいタスクが設定されると、以前のタスクは自動的にキャンセルされます。
    private var mazeSnapshotTask: Task<(), Never>? {
        didSet {
            oldValue?.cancel()
        }
    }

    /// Initializes the ViewModel with the specified width and height for the maze.
    /// 指定された幅と高さで迷路を管理する ViewModel を初期化します。
    ///
    /// This initializer also ensures the width and height become odd numbers, enabling an outer wall around the maze.
    /// イニシャライザで width, height を奇数に揃え、迷路の外周を壁として扱いやすくしています。
    init(width: Int, height: Int) {
        let width = (width / 2) * 2 + 1
        let height = (height / 2) * 2 + 1
        self.mazeModel = MazeGenerator(width: width, height: height)
        setUp()
    }

    /// Asynchronously triggers the maze generation in the actor.
    /// actor での迷路生成を非同期的に呼び出します。
    func generate() async {
        await mazeModel.generate()
    }

    /// Sets up a task to subscribe to the actor's snapshot stream.
    /// actor のスナップショットストリームを購読するタスクを設定します。
    private func setUp() {
        mazeSnapshotTask = Task { [weak self, mazeModel] in
            for await snapshot in await mazeModel.snapshots {
                guard let self else { break }
                try? await Task.sleep(for: .milliseconds(30))
                self.tiles = await makeTiles(snapshot: snapshot)
                self.isGenerating = snapshot.isGenerating
            }
        }
    }
}

private func makeTiles(snapshot: MazeGenerator.Snapshot) async -> [[MazeTile]] {
    await Task.detached {
        let isGenerating = snapshot.isGenerating
        var tiles: [[MazeTile]] = snapshot.grid.map { row in
            row.map { $0 ? .path : .wall }
        }
        if isGenerating, tiles.count > 1, tiles[1].count > 1 {
            return tiles
        } else {
            tiles[1][1] = .start
            tiles[snapshot.grid.count - 2][snapshot.grid[1].count - 2] = .goal
            return tiles
        }
    }
    .value
}
