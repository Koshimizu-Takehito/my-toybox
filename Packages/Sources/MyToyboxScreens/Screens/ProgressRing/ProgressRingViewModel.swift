import Foundation
import Observation
import SwiftUI

/// A view model that manages the progress state and its animation lifecycle.
@MainActor
@Observable
final class ProgressRingViewModel {
    /// The current progress value (from 0.0 to 1.0).
    var progress: Double = 0

    /// Indicates whether the progress animation is paused.
    /// If `task` is `nil`, the animation is considered paused.
    var isPaused: Bool {
        task == nil
    }

    /// The internal task responsible for driving the progress animation.
    /// Automatically cancels any previous task when reassigned (via `didSet`).
    private var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    /// Starts the progress animation from 0. Resets `progress` before resuming.
    func start() {
        progress = 0
        resume()
    }

    /// Stops the animation and resets progress to 0.
    func reset() {
        pause()
        progress = 0
    }

    /// Pauses the current animation by canceling the internal Task.
    func pause() {
        task = nil
    }

    /// Resumes the animation from the current `progress` value up to 1.0.
    /// Uses a linear animation and sleeps briefly between increments for a smooth progression.
    func resume() {
        task = Task {
            // Convert current progress to a starting integer, then go up to 1000 (representing 100% in 0.1% steps).
            for i in Int(progress * 1000) ... 1000 {
                if Task.isCancelled {
                    break
                }
                withAnimation(.linear) {
                    progress = Double(i) / 1000.0
                }
                try? await Task.sleep(for: .milliseconds(3))
            }
        }
    }
}
