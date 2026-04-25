import AVFoundation
import CoreImage
import QuartzCore

/// An observable video provider that pulls frames from `AVPlayer` for use in SwiftUI.
///
/// The provider drives the playback pipeline through a single linear async task,
/// so state transitions are deterministic and resource ownership is easy to reason
/// about: cancelling the task is equivalent to tearing the pipeline down.
@MainActor
@Observable
final class VideoImageProvider {
    /// The externally visible state of the playback pipeline.
    enum State: Equatable {
        case idle
        case loading
        case playing
        case paused
        case failed(String)
    }

    /// The most recent video frame as a `CGImage`.
    private(set) var image: CGImage?

    /// The current lifecycle state of the video pipeline.
    private(set) var state: State = .idle

    /// The total duration of the loaded video, in seconds.
    private(set) var duration: Double = 0

    /// The current playback time, in seconds.
    private(set) var currentTime: Double = 0

    /// A Boolean value that indicates whether playback is currently paused.
    var isPaused: Bool {
        switch state {
        case .playing: false
        default: true
        }
    }

    /// The audio volume applied to the underlying player.
    var volume: Float = 1.0 {
        didSet { player?.volume = volume }
    }

    /// A normalized progress value for the current playback position.
    var progress: Double {
        get {
            guard duration > 0 else { return 0 }
            return currentTime / duration
        }
        set {
            guard duration > 0 else { return }
            seek(to: max(0, min(1, newValue)) * duration)
        }
    }

    private let context = CIContext()
    private let url: URL

    @ObservationIgnored private var player: AVPlayer?
    @ObservationIgnored private var output: AVPlayerItemVideoOutput?
    @ObservationIgnored private var playbackTask: Task<Void, Never>?

    #if os(iOS) || os(tvOS)
    @ObservationIgnored private var displayLink: CADisplayLink?
    #else
    @ObservationIgnored private var displayLink: Timer?
    #endif

    init(url: URL) {
        self.url = url
    }

    isolated deinit {
        playbackTask?.cancel()
        teardown()
    }

    // MARK: - Public control

    /// Starts the playback pipeline. Idempotent: calling again while already running
    /// is a no-op until ``stop()`` is invoked.
    func start() {
        guard playbackTask == nil else { return }

        state = .loading
        image = nil
        duration = 0
        currentTime = 0

        playbackTask = Task { [weak self] in
            guard let self else { return }
            await runPlayback()
        }
    }

    /// Cancels the playback pipeline and releases all resources.
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        teardown()
        state = .idle
    }

    /// Tears down a failed pipeline and rebuilds it from scratch.
    func retry() {
        stop()
        start()
    }

    /// Resumes playback if it was paused. No-op while loading or in failure.
    func resume() {
        guard let player else {
            if case .idle = state { start() }
            return
        }
        guard case .paused = state else { return }
        player.play()
        setDisplayLinkPaused(false)
        state = .playing
    }

    /// Pauses playback if it is currently playing.
    func pause() {
        guard let player, case .playing = state else { return }
        player.pause()
        setDisplayLinkPaused(true)
        state = .paused
    }

    /// Toggles between playing and pausing.
    func toggle() {
        switch state {
        case .playing: pause()
        case .paused, .idle: resume()
        case .loading, .failed: break
        }
    }

    /// Resets playback to the beginning of the video.
    func reset() {
        guard let player else { return }
        let zero = CMTime.zero
        currentTime = 0
        player.seek(to: zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.copyFrame(at: zero)
            }
        }
    }

    /// Seeks the player to the specified time.
    func seek(to seconds: Double) {
        guard let player else { return }
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        currentTime = seconds
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.copyFrame(at: time)
            }
        }
    }

    // MARK: - Pipeline

    private func runPlayback() async {
        do {
            let asset = AVURLAsset(url: url)
            let (isPlayable, loadedDuration) = try await asset.load(.isPlayable, .duration)
            try Task.checkCancellation()
            guard isPlayable else {
                state = .failed("The video is not playable on this device.")
                return
            }

            let output = AVPlayerItemVideoOutput(outputSettings: [
                AVVideoAllowWideColorKey: true,
                AVVideoColorPropertiesKey: [
                    AVVideoColorPrimariesKey: AVVideoColorPrimaries_P3_D65,
                    AVVideoTransferFunctionKey: AVVideoTransferFunction_Linear,
                    AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_2020,
                ],
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(
                    value: kCVPixelFormatType_64RGBAHalf
                ),
            ])
            let item = AVPlayerItem(asset: asset)
            item.add(output)

            let player = AVPlayer(playerItem: item)
            player.volume = volume
            player.automaticallyWaitsToMinimizeStalling = true

            // Pipeline ownership transfers to `self` here. Subsequent teardown
            // is the responsibility of `stop()` / `pause()` / `fail`-path below.
            self.output = output
            self.player = player
            duration = loadedDuration.seconds.isFinite && loadedDuration.seconds > 0
                ? loadedDuration.seconds : 0

            makeDisplayLink()
            player.play()
            state = .playing
        } catch is CancellationError {
            // Cancelled via stop(); resources (if any) are torn down by stop() itself.
        } catch {
            teardown()
            state = .failed("The video could not be loaded: \(error.localizedDescription)")
        }
    }

    private func teardown() {
        displayLink?.invalidate()
        displayLink = nil
        player?.pause()
        player = nil
        output = nil
    }

    // MARK: - Frame clock

    private func makeDisplayLink() {
        guard displayLink == nil else { return }
        #if os(iOS) || os(tvOS)
        let link = CADisplayLink(
            target: self,
            selector: #selector(displayLinkFired(link:))
        )
        link.add(to: .main, forMode: .common)
        displayLink = link
        #else
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.copyPixelBuffer(hostTime: CACurrentMediaTime())
            }
        }
        displayLink = timer
        #endif
    }

    private func setDisplayLinkPaused(_ paused: Bool) {
        #if os(iOS) || os(tvOS)
        displayLink?.isPaused = paused
        #else
        if paused {
            displayLink?.invalidate()
            displayLink = nil
        } else {
            makeDisplayLink()
        }
        #endif
    }

    #if os(iOS) || os(tvOS)
    @objc private func displayLinkFired(link: CADisplayLink) {
        copyPixelBuffer(hostTime: link.timestamp)
    }
    #endif

    private func copyPixelBuffer(hostTime: CFTimeInterval) {
        guard let player, let output else { return }

        let current = player.currentTime().seconds
        if current.isFinite {
            currentTime = current
        }

        let itemTime = output.itemTime(forHostTime: hostTime)
        guard itemTime.isValid, output.hasNewPixelBuffer(forItemTime: itemTime) else {
            return
        }
        copyFrame(at: itemTime)
    }

    private func copyFrame(at itemTime: CMTime) {
        guard let output else { return }
        guard let buffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            image = cgImage
        }
    }
}
