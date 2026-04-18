import Foundation

/// Tracks wall-clock time spent while the sidebar list is scrolling so thumbnail `ThumbnailView` can pass a continuous logical time.
struct ThumbnailScrollPauseAccumulator {
    private(set) var accumulatedPauseDuration: TimeInterval = 0
    private var pauseStart: Date?

    /// - Parameters:
    ///   - oldValue: Previous `isScrolling` from `onChange(of:initial:)`.
    ///   - newValue: Current `isScrolling`.
    ///   - now: Clock reading for the transition (typically `Date()`).
    ///
    /// When `initial` is `true`, the first invocation may pass equal values; if both are `true`, the list was already scrolling when the view appeared and scroll tracking starts at `now`.
    mutating func onScrollingChanged(oldValue: Bool, newValue: Bool, now: Date) {
        if oldValue != newValue {
            if newValue {
                pauseStart = now
            } else {
                if let start = pauseStart {
                    accumulatedPauseDuration += now.timeIntervalSince(start)
                }
                pauseStart = nil
            }
        } else if newValue {
            pauseStart = now
        }
    }

    func logicalTime(wallElapsed: TimeInterval) -> TimeInterval {
        wallElapsed - accumulatedPauseDuration
    }
}
