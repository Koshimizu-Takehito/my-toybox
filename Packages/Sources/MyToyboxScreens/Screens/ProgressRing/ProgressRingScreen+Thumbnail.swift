import SwiftUI

extension ProgressRingScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        Thumbnail(isScrolling: isScrolling, time: time)
    }

    struct Thumbnail: View {
        @State private var viewModel = ProgressRingViewModel()
        var isScrolling: Bool, time: TimeInterval

        var body: some View {
            GeometryReader { geometry in
                let width = min(geometry.size.width, geometry.size.height)
                ProgressRing(lineWidth: 0.08 * width, value: viewModel.progress) { progressValue in
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("\(Int(progressValue * 100))")
                        Text("%")
                    }
                    .font(.system(size: 0.16 * width))
                    .minimumScaleFactor(0.1)
                    .monospacedDigit()
                    .padding(0.5 * width)
                }
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(0.15 * width)
            }
            .onChange(of: time) { _, time in
                let progress = (time / 4.0).truncatingRemainder(dividingBy: 1.0)
                viewModel.progress = progress
            }
        }
    }
}

#Preview {
    ProgressRingScreen.thumbnail
}
