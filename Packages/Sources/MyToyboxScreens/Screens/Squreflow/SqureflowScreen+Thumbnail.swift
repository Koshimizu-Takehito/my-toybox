import SwiftUI

extension SqureflowScreen {
    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        SqureflowScreenThumbnailContent(isScrolling: isScrolling, time: time)
    }
}

// MARK: - SqureflowScreenThumbnailContent

private struct SqureflowScreenThumbnailContent: View {
    var isScrolling: Bool
    var time: TimeInterval
    @State private var holder = SquresHolder()

    var body: some View {
        let date = Date(timeIntervalSinceReferenceDate: time)
        Canvas { context, size in
            holder.update(at: date, in: size, allowSpawn: !isScrolling)
            for item in holder.squre {
                let shape = item.path(in: size, date: date)
                context.fill(shape, with: .color(item.color))
            }
        }
    }
}

#Preview {
    SqureflowScreen.thumbnail
}
