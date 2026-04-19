import Foundation
@testable import MyToyboxCore
import Testing

@Suite struct ScrollPauseAccumulatorTests {
    @Test func idleThenScrollThenIdle() {
        let t0 = Date(timeIntervalSinceReferenceDate: 1000)
        let t1 = t0.addingTimeInterval(2)
        let t2 = t1.addingTimeInterval(5)
        let t3 = t2.addingTimeInterval(1)

        var accumulator = ScrollPauseAccumulator()

        // Idle (no `beginScrollSegment` / `endScrollSegment` yet); `t0` anchors later timestamps.
        #expect(accumulator.accumulatedPauseDuration == 0)
        #expect(accumulator.logicalTime(wallElapsed: 10) == 10)

        accumulator.beginScrollSegment(at: t1)
        #expect(accumulator.accumulatedPauseDuration == 0)

        accumulator.endScrollSegment(at: t2)
        #expect(accumulator.accumulatedPauseDuration == 5)

        let wallElapsedAfterScroll = 100.0
        #expect(accumulator.logicalTime(wallElapsed: wallElapsedAfterScroll) == 95)

        accumulator.beginScrollSegment(at: t2)
        accumulator.endScrollSegment(at: t3)
        #expect(accumulator.accumulatedPauseDuration == 6)
    }

    @Test func initialAlreadyScrolling() {
        let t0 = Date(timeIntervalSinceReferenceDate: 2000)
        let t1 = t0.addingTimeInterval(3)

        var accumulator = ScrollPauseAccumulator()

        accumulator.beginScrollSegment(at: t0)
        #expect(accumulator.accumulatedPauseDuration == 0)

        accumulator.endScrollSegment(at: t1)
        #expect(accumulator.accumulatedPauseDuration == 3)
    }

    @Test func logicalTimeStaysContinuousAcrossResume() {
        let mount = Date(timeIntervalSinceReferenceDate: 5000)
        let scrollStart = mount.addingTimeInterval(1)
        let scrollEnd = scrollStart.addingTimeInterval(4)

        var accumulator = ScrollPauseAccumulator()

        let wallBeforeScroll = scrollStart.timeIntervalSince(mount)
        accumulator.beginScrollSegment(at: scrollStart)
        #expect(accumulator.logicalTime(wallElapsed: wallBeforeScroll) == wallBeforeScroll)

        accumulator.endScrollSegment(at: scrollEnd)
        let wallAfterResume = scrollEnd.timeIntervalSince(mount)
        let logicalAfterResume = accumulator.logicalTime(wallElapsed: wallAfterResume)
        #expect(abs(logicalAfterResume - wallBeforeScroll) < 0.001)
    }
}
