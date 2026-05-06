import MyToyboxCore
import SwiftUI

extension MazeGeneratorScreen {
    @ViewBuilder
    public static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Thumbnail()
    }

    struct Thumbnail: View {
        @State private var viewModel = MazeGeneratorViewModel(width: 16, height: 16)
        @State private var viewID = UUID()

        var body: some View {
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0 ..< viewModel.tiles.count, id: \.self) { i in
                    GridRow(alignment: .center) {
                        ForEach(0 ..< viewModel.tiles[i].count, id: \.self) { j in
                            MazeTileView(tile: viewModel.tiles[i][j])
                        }
                    }
                }
            }
            .onChange(of: viewModel.isGenerating) { _, isGenerating in
                if !isGenerating {
                    Task {
                        try await Task.sleep(for: .milliseconds(600))
                        viewID = .init()
                    }
                }
            }
            .task(id: viewID) {
                await viewModel.generate()
            }
        }
    }
}

#Preview {
    MazeGeneratorScreen.thumbnail
}
