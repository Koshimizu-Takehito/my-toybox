import SwiftUI

public extension EnvironmentValues {
    @Entry var isScrolling = false
}

// MARK: - ThumbnailView

/// Wraps screen thumbnails and forwards scroll state plus a logical animation time to the ``ScreenMetadata`` thumbnail builder.
///
/// Thumbnails used to advance via ``TimelineView`` with a scroll-adjusted clock so motion stayed phase-continuous while scrolling.
/// That setup crashed when pushing the detail screen or popping back to the list, so timeline-driven updates were removed.
///
/// `isScrolling` is still read from the environment for API compatibility and possible future use; animation time is held constant so thumbnails stay
/// visually static.
public struct ThumbnailView<Content: View>: View {
    @Environment(\.isScrolling) private var isScrolling
    private var content: (_ isScrolling: Bool, _ time: TimeInterval) -> Content

    public init(@ViewBuilder content: @escaping (_ isScrolling: Bool, _ time: TimeInterval) -> Content) {
        self.content = content
    }

    public var body: some View {
        // Constant logical time freezes thumbnail animation. `Double.pi / 2` is an arbitrary fixed phase (no mathematical significance).
        content(isScrolling, Double.pi / 2)
    }
}
