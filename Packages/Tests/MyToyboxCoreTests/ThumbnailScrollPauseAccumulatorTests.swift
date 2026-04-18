import Foundation
@testable import MyToyboxCore
import Testing

@Test func scrollPauseAccumulator_idleThenScrollThenIdle() {
    let t0 = Date(timeIntervalSinceReferenceDate: 1_000)
    let t1 = t0.addingTimeInterval(2)
    let t2 = t1.addingTimeInterval(5)
    let t3 = t2.addingTimeInterval(1)

    var accumulator = ThumbnailScrollPauseAccumulator()

    accumulator.onScrollingChanged(oldValue: false, newValue: false, now: t0)
    #expect(accumulator.accumulatedPauseDuration == 0)
    #expect(accumulator.logicalTime(wallElapsed: 10) == 10)

    accumulator.onScrollingChanged(oldValue: false, newValue: true, now: t1)
    #expect(accumulator.accumulatedPauseDuration == 0)

    accumulator.onScrollingChanged(oldValue: true, newValue: false, now: t2)
    #expect(accumulator.accumulatedPauseDuration == 5)

    let wallElapsedAfterScroll = 100.0
    #expect(accumulator.logicalTime(wallElapsed: wallElapsedAfterScroll) == 95)

    accumulator.onScrollingChanged(oldValue: false, newValue: true, now: t2)
    accumulator.onScrollingChanged(oldValue: true, newValue: false, now: t3)
    #expect(accumulator.accumulatedPauseDuration == 6)
}

@Test func scrollPauseAccumulator_initialAlreadyScrolling() {
    let t0 = Date(timeIntervalSinceReferenceDate: 2_000)
    let t1 = t0.addingTimeInterval(3)

    var accumulator = ThumbnailScrollPauseAccumulator()

    accumulator.onScrollingChanged(oldValue: true, newValue: true, now: t0)
    #expect(accumulator.accumulatedPauseDuration == 0)

    accumulator.onScrollingChanged(oldValue: true, newValue: false, now: t1)
    #expect(accumulator.accumulatedPauseDuration == 3)
}

@Test func scrollPauseAccumulator_logicalTimeStaysContinuousAcrossResume() {
    let mount = Date(timeIntervalSinceReferenceDate: 5_000)
    let scrollStart = mount.addingTimeInterval(1)
    let scrollEnd = scrollStart.addingTimeInterval(4)

    var accumulator = ThumbnailScrollPauseAccumulator()

    let wallBeforeScroll = scrollStart.timeIntervalSince(mount)
    accumulator.onScrollingChanged(oldValue: false, newValue: true, now: scrollStart)
    #expect(accumulator.logicalTime(wallElapsed: wallBeforeScroll) == wallBeforeScroll)

    accumulator.onScrollingChanged(oldValue: true, newValue: false, now: scrollEnd)
    let wallAfterResume = scrollEnd.timeIntervalSince(mount)
    let logicalAfterResume = accumulator.logicalTime(wallElapsed: wallAfterResume)
    #expect(abs(logicalAfterResume - wallBeforeScroll) < 0.001)
}
