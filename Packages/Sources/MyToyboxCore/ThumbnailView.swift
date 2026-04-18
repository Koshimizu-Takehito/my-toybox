import SwiftUI

public extension EnvironmentValues {
    @Entry var isScrolling = false
}

// MARK: - ThumbnailView

public struct ThumbnailView<Content: View>: View {
    @State private var now = Date.now
    @State private var scrollPauseAccumulator = ThumbnailScrollPauseAccumulator()
    @Environment(\.isScrolling) private var isScrolling
    private var content: (_ isScrolling: Bool, _ time: TimeInterval) -> Content

    public init(@ViewBuilder content: @escaping (_ isScrolling: Bool, _ time: TimeInterval) -> Content) {
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation(paused: isScrolling)) { context in
            let wallElapsed = context.date.timeIntervalSince(now)
            let logicalTime = scrollPauseAccumulator.logicalTime(wallElapsed: wallElapsed)
            content(isScrolling, logicalTime)
                .transaction { transaction in
                    transaction.animation = !isScrolling ? transaction.animation : nil
                    transaction.disablesAnimations = isScrolling
                }
        }
        .onChange(of: isScrolling, initial: true) { oldValue, newValue in
            var accumulator = scrollPauseAccumulator
            accumulator.onScrollingChanged(oldValue: oldValue, newValue: newValue, now: Date())
            scrollPauseAccumulator = accumulator
        }
    }
}
