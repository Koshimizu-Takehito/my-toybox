import SwiftUI

extension GameOfLifeScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> Thumbnail {
        Thumbnail(isScrolling: isScrolling, time: time)
    }

    public struct Thumbnail: View {
        @State private var viewModel = GameOfLifeViewModel(cycleIntervalMS: 10.0, size: 10)

        var isScrolling: Bool, time: TimeInterval

        public var body: some View {
            let trigger = Int((time / 2.0).truncatingRemainder(dividingBy: 3.0))
            MetalGameOfLifeView(viewModel: viewModel)
                .onAppear { reset() }
                .id(trigger)
                .id(isScrolling)
        }

        private func reset() {
            viewModel.resetStats()
            viewModel.resetView()
            let s = viewModel.size // 再初期化
            viewModel.size = s
            viewModel.isRunning = !isScrolling
        }
    }
}

#Preview {
    GameOfLifeScreen.thumbnail
        .colorScheme(.dark)
}
