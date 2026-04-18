import SwiftUI

public extension EnvironmentValues {
    @Entry var isScrolling = false
}

// MARK: - ThumbnailView

public struct ThumbnailView<Content: View>: View {
    @State private var now = Date.now
    @Environment(\.isScrolling) private var isScrolling
    private var content: (_ isScrolling: Bool, _ time: TimeInterval) -> Content

    public init(@ViewBuilder content: @escaping (_ isScrolling: Bool, _ time: TimeInterval) -> Content) {
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation(paused: isScrolling)) { context in
            content(isScrolling, context.date.timeIntervalSince(now))
                .transaction { transaction in
                    transaction.animation = !isScrolling ? transaction.animation : nil
                    transaction.disablesAnimations = isScrolling
                }
        }
    }
}
