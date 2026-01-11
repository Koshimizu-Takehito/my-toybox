import AVFoundation
import CoreImage

/// An observable video provider that pulls frames from `AVPlayer` for use in SwiftUI.
///
/// `VideoImageProvider` is responsible for:
/// - Loading a remote video asset
/// - Driving playback via `AVPlayer`
/// - Extracting frames using `AVPlayerItemVideoOutput`
/// - Providing the latest frame as a `CGImage`
/// - Tracking duration and current playback time
/// - Exposing a normalized progress value suitable for scrubbing with a slider
@MainActor
@Observable
final class VideoImageProvider {
    /// The most recent video frame as a `CGImage`.
    ///
    /// This value is updated on every display refresh when a new pixel buffer
    /// is available from `AVPlayerItemVideoOutput`.
    private(set) var image: CGImage?

    /// A Boolean value that indicates whether playback is currently paused.
    ///
    /// Updating this property also pauses or resumes the associated
    /// display link so that frame extraction is aligned with playback.
    private(set) var isPaused: Bool = false {
        didSet { displayLink?.isPaused = isPaused }
    }

    /// The total duration of the loaded video, in seconds.
    private(set) var duration: Double = 0

    /// The current playback time, in seconds.
    private(set) var currentTime: Double = 0

    /// The Core Image context used to convert pixel buffers into `CGImage` values.
    private let context = CIContext()

    /// The remote video URL used to create the `AVPlayerItem`.
    private let url: URL

    /// The underlying `AVPlayer` instance that manages playback.
    @ObservationIgnored private var player: AVPlayer?

    /// The video output used to pull decoded frames from the player item.
    @ObservationIgnored private var output: AVPlayerItemVideoOutput!

    /// A key-value observation used to detect when the player item becomes ready to play.
    @ObservationIgnored private var observer: NSKeyValueObservation?

    /// A display link that synchronizes frame extraction with the screen refresh rate.
    ///
    /// The display link is created lazily when the player item becomes ready
    /// and is invalidated when ``stop()`` is called or when the provider
    /// is deallocated.
    @ObservationIgnored private var displayLink: CADisplayLink?

    /// The audio volume applied to the underlying player.
    ///
    /// Valid values are in the range `0.0` (muted) to `1.0` (full volume).
    var volume: Float = 1.00 {
        didSet { player?.volume = volume }
    }

    /// A normalized progress value for the current playback position.
    ///
    /// The value is in the range `0.0...1.0` and is derived from
    /// ``currentTime`` and ``duration``. Assigning a new value
    /// seeks the player to the corresponding position.
    var progress: Double {
        get {
            guard duration > 0 else { return 0 }
            return currentTime / duration
        }
        set {
            guard duration > 0 else { return }
            let clamped = max(0, min(1, newValue))
            let seconds = clamped * duration
            seek(to: seconds)
        }
    }

    /// Creates a new video provider for the specified URL.
    ///
    /// The actual loading and playback setup is performed by calling ``start()``.
    ///
    /// - Parameter url: The remote video URL to load and play.
    init(url: URL) {
        self.url = url
    }

    /// Cleans up playback resources when the provider is deallocated.
    ///
    /// The display link is invalidated, the player is paused, and any
    /// KVO observers are invalidated.
    isolated deinit {
        displayLink?.invalidate()
        player?.pause()
        observer?.invalidate()
    }

    /// Pauses video playback.
    ///
    /// This method does nothing if the player has not been created yet.
    func pause() {
        player?.pause()
        isPaused = true
    }

    /// Stops playback and releases underlying playback resources.
    ///
    /// This method invalidates the display link, removes the KVO observer,
    /// pauses the player, and releases the player instance. After calling
    /// this method, you can call ``start()`` again to recreate the pipeline.
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        observer?.invalidate()
        observer = nil
        player?.pause()
        player = nil
    }

    /// Starts or resumes video playback.
    ///
    /// If the player has not been created yet, this method initializes it
    /// and starts playback once the asset is ready. Otherwise, it simply
    /// resumes playback from the current position.
    func resume() {
        guard let player else {
            return start()
        }
        player.play()
        isPaused = false
    }

    /// Toggles between playing and pausing the video.
    func toggle() {
        isPaused ? resume() : pause()
    }

    /// Resets playback to the beginning of the video.
    ///
    /// If the player has not been created yet, this method does nothing.
    /// Use ``resume()`` afterwards to immediately start playback from the start.
    func reset() {
        // If the player does not exist, there is nothing to reset.
        guard let player else { return }

        // Seek to the beginning (0 seconds).
        player.seek(to: .zero)
        currentTime = .zero
    }

    /// Seeks the player to the specified time.
    ///
    /// - Parameter seconds: The new playback time in seconds.
    func seek(to seconds: Double) {
        guard let player else { return }
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = seconds
    }

    /// Creates and configures the underlying `AVPlayer` and its video output.
    ///
    /// This method is typically called once when the view appears. It sets up
    /// the player item, video output, and KVO observer used to detect when
    /// the asset becomes ready for playback. Once ready, a display link is
    /// created and playback begins.
    func start() {
        guard player == nil else {
            return resume()
        }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = volume

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
        self.output = output
        observer = item.observe(\.status, options: [.new, .old], changeHandler: { item, _ in
            guard item.status == .readyToPlay else {
                return
            }
            item.add(output)
            MainActor.assumeIsolated {
                Task {
                    self.duration = try await item.asset.load(.duration).seconds
                }
                self.currentTime = 0
                self.makeDisplayLinkIfNeeded()
                self.resume()
            }
        })
    }

    /// Lazily creates and registers the display link used for frame extraction.
    ///
    /// The display link is added to the main run loop with the `.common` mode
    /// and configured to call ``copyPixelBuffers(link:)`` on every screen refresh.
    private func makeDisplayLinkIfNeeded() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(
            target: self,
            selector: #selector(copyPixelBuffers(link:))
        )
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Copies the latest video frame from the player into ``image``.
    ///
    /// This method is invoked on every screen refresh by the display link.
    /// When a new pixel buffer is available, it is converted into a `CGImage`
    /// via Core Image and published to SwiftUI. The current playback time is
    /// also updated from the underlying player.
    ///
    /// - Parameter link: The display link that triggered this callback.
    @objc private func copyPixelBuffers(link: CADisplayLink) {
        let time = output.itemTime(forHostTime: link.timestamp)
        let hasBuffer = output.hasNewPixelBuffer(forItemTime: time)
        if hasBuffer, let buffer = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) {
            let image = CIImage(cvPixelBuffer: buffer)
            self.image = context.createCGImage(image, from: image.extent)
            if let player {
                currentTime = player.currentTime().seconds
            }
        }
    }
}
