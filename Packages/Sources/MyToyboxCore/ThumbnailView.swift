import SwiftUI

public extension EnvironmentValues {
    @Entry var isScrolling = false
}

// MARK: - ThumbnailView

public struct ThumbnailView<Content: View>: View {
    @State private var now = Date.now
    @State private var accumulator = ScrollPauseAccumulator()
    @Environment(\.isScrolling) private var isScrolling
    private var content: (_ isScrolling: Bool, _ time: TimeInterval) -> Content

    public init(@ViewBuilder content: @escaping (_ isScrolling: Bool, _ time: TimeInterval) -> Content) {
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation(paused: isScrolling)) { context in
            let wallElapsed = context.date.timeIntervalSince(now)
            let logicalTime = accumulator.logicalTime(wallElapsed: wallElapsed)
            content(isScrolling, logicalTime)
                .transaction { transaction in
                    transaction.animation = !isScrolling ? transaction.animation : nil
                    transaction.disablesAnimations = isScrolling
                }
        }
        .onChange(of: isScrolling, initial: true) { oldValue, newValue in
            if newValue {
                accumulator.beginScrollSegment()
            } else if oldValue != newValue {
                accumulator.endScrollSegment()
            }
        }
    }
}

// MARK: - ScrollPauseAccumulator

/// Accumulates wall-clock duration spent in the scrolling state so ``ThumbnailView`` can
/// subtract it from timeline elapsed time and keep animation phase continuous after the list stops.
///
/// Call ``beginScrollSegment(at:)`` when `isScrolling` becomes or stays `true`, and
/// ``endScrollSegment(at:)`` when it transitions from `true` to `false`. Skip both when
/// `oldValue == newValue` (e.g. initial `false → false` while idle).
struct ScrollPauseAccumulator {
    /// Sum of intervals where the list was scrolling, measured in wall time (`now` at each update).
    ///
    /// `private(set)` restricts writes to this type (``beginScrollSegment(at:)`` / ``endScrollSegment(at:)``).
    /// The getter stays module-internal so the package test target can read this property with
    /// `@testable import MyToyboxCore`; a plain `private` property would hide it from tests, and
    /// `package` would widen visibility beyond what production needs.
    private(set) var accumulatedPauseDuration = 0.0
    private var pauseStart: Date?

    /// Marks `now` as the start of the current list-scroll segment (entering or continuing scroll).
    mutating func beginScrollSegment(at now: Date = .now) {
        pauseStart = now
    }

    /// Ends the open segment: adds its wall duration to ``accumulatedPauseDuration`` and clears ``pauseStart``.
    mutating func endScrollSegment(at now: Date = .now) {
        if let start = pauseStart {
            accumulatedPauseDuration += now.timeIntervalSince(start)
        }
        pauseStart = nil
    }

    /// Elapsed time minus ``accumulatedPauseDuration`` (logical animation clock for thumbnails).
    func logicalTime(wallElapsed: TimeInterval) -> TimeInterval {
        wallElapsed - accumulatedPauseDuration
    }
}
