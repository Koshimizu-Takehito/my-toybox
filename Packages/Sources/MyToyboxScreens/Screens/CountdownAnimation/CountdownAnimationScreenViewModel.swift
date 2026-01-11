import Foundation
import Observation

/// A countdown timer model that updates continuously at 360 frames per second.
///
/// This view model is marked as `@Observable` so that SwiftUI can automatically
/// update the view whenever `count` changes.
@MainActor
@Observable
final class CountdownAnimationScreenViewModel {
    /// The current countdown value in seconds.
    /// Starts at 10 and decrements smoothly over time.
    private(set) var count: Double = 10

    /// The active countdown task.
    /// Automatically cancels any previous task when reassigned.
    private(set) var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    /// Restarts the countdown from 10 seconds.
    /// Begins a new high-frequency timer and decrements the `count` accordingly.
    func restart() {
        count = 10
        task = Task { [weak self] in
            let interval = 1.0 / 360.0 // ~60fps * 6 for ultra smooth UI updates
            let timer = Timer
                .publish(every: interval, on: .main, in: .common)
                .autoconnect()

            for await _ in timer.values {
                guard let self, count > 0 else {
                    break
                }
                count -= interval
            }
        }
    }
}
