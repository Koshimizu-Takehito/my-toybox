import SwiftUI

// MARK: - RealTimeMosicScreen

/// A sample view that plays a remote video and applies a controllable mosaic shader.
///
/// This view demonstrates how to:
/// - Pull video frames from `AVPlayer` using `AVPlayerItemVideoOutput`
/// - Render them in SwiftUI as a `CGImage`
/// - Apply a custom Metal-based mosaic effect using `ShaderLibrary`
/// - Interactively control both the video playback position and the
///   mosaic split position with SwiftUI gestures and controls.
struct RealTimeMosicScreen: View {
    /// A Boolean value that toggles the mosaic shader on and off.
    @State private var isOn = true

    /// A Boolean value that controls the visibility of the playback UI.
    @State private var showsControls = false

    /// An observable object that provides decoded video frames and playback state.
    @State private var provider = VideoImageProvider(
        url: URL(
            string: "https://devstreaming-cdn.apple.com/videos/wwdc/2025/102/2/137f7e3a-caee-4bb1-bdea-adca731aa1ed/downloads/wwdc2025-102_hd.mp4"
        )!
    )

    /// The size of the content area used to normalize the drag position.
    @State private var size: CGSize = .zero

    /// The current horizontal offset of the mosaic split bar, in points.
    ///
    /// This value is relative to the center of the content area.
    @State private var barOffset: CGFloat = 0

    /// The horizontal offset of the mosaic bar at the start of a drag gesture.
    @State private var barStartOffset: CGFloat = 0

    var body: some View {
        screen()
            .overlay(content: mosaicBar)
            .onTapGesture { showsControls.toggle() }
            .overlay(content: control)
            .onGeometryChange(for: CGSize.self, of: \.size) { size = $1 }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear(perform: provider.start)
            .onDisappear(perform: provider.stop)
            .animation(.default, value: showsControls)
            .tint(.blue)
    }

    /// Renders the current video frame or a placeholder while the video is loading.
    ///
    /// When a frame is available, it is drawn as a resizable image and passed
    /// through the ``MosaicEffect`` modifier. Otherwise, a background rectangle
    /// fills the space.
    @ViewBuilder
    private func screen() -> some View {
        if let image = provider.image {
            Image(decorative: image, scale: 1)
                .resizable()
                .scaledToFit()
                .modifier(MosaicEffect(isOn: isOn, offset: barOffset / max(size.width, 1) + 0.5))
        } else {
            Rectangle().foregroundStyle(.background)
        }
    }

    /// A draggable vertical bar that controls the mosaic split position.
    ///
    /// The bar is horizontally draggable within the bounds of the content size.
    /// Its position is normalized and passed as the `offset` parameter to the
    /// mosaic shader so that the shader can adjust where the effect is applied.
    @ViewBuilder
    private func mosaicBar() -> some View {
        Color.red
            .opacity(isOn ? 1.0 : 0.0)
            .frame(width: 2)
            .padding(.horizontal)
            .contentShape(.rect)
            .offset(x: barOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Drag from the original offset plus the translation.
                        barOffset = barStartOffset + value.translation.width
                        barOffset = min(max(-size.width / 2, barOffset), size.width / 2)
                    }
                    .onEnded { _ in
                        // Persist the offset as the new baseline for the next drag.
                        barStartOffset = barOffset
                    }
            )
    }

    /// Renders the playback controls and scrubber overlay.
    ///
    /// The controls are only shown once the first frame is available. Tapping
    /// anywhere on the content toggles the visibility of the controls.
    @ViewBuilder
    private func control() -> some View {
        if provider.image != nil {
            let control = VStack {
                HStack {
                    if showsControls {
                        let buttonName = provider.isPaused ? "play" : "pause"
                        Button(buttonName.capitalized, systemImage: buttonName, action: provider.toggle)
                        Button(action: provider.reset) {
                            Image(systemName: "arrow.trianglehead.counterclockwise")
                        }
                    }
                    Spacer()
                    Toggle("Filter", isOn: $isOn.animation())
                        .fixedSize()
                        .shadow(radius: 1)
                }
                if showsControls {
                    slider()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding()
            .fontWeight(.black)

            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                control.buttonStyle(.glass)
            } else {
                control
            }
        }
    }

    /// A slider that scrubs the video playback position.
    ///
    /// The slider is bound to ``VideoImageProvider/progress``, which maps
    /// the current time and total duration to a 0–1 range. The slider also
    /// displays the current playback time and total duration.
    @ViewBuilder
    private func slider() -> some View {
        Slider(value: $provider.progress, in: 0 ... 1) {
            Text("Position")
        } minimumValueLabel: {
            Text(timeString(from: provider.currentTime))
        } maximumValueLabel: {
            Text(timeString(from: provider.duration))
        }
        .monospacedDigit()
        .shadow(radius: 1)
        .padding(.horizontal)
        .font(.caption2)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.ultraThinMaterial)
        }
    }

    /// Formats a time interval in seconds as a human-readable string.
    ///
    /// The returned string uses the `m:ss` format and falls back to `--:--`
    /// if the value is not finite.
    ///
    /// - Parameter seconds: The time interval in seconds.
    /// - Returns: A formatted string such as `"1:23"` or `"--:--"`.
    private func timeString(from seconds: Double) -> String {
        guard seconds.isFinite, !seconds.isNaN else { return "--:--" }
        let total = Int(seconds.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - MosaicEffect

/// A view modifier that applies a mosaic shader to its content.
///
/// The underlying shader is provided by ``ShaderLibrary/mosaic`` and receives
/// the view's bounding rectangle, the mosaic scale, and a normalized split
/// offset. This modifier does not animate over time by itself; instead, it
/// recomputes the shader whenever its `isOn` or `offset` properties change.
struct MosaicEffect: ViewModifier {
    /// A Boolean value that controls whether the mosaic effect is enabled.
    var isOn: Bool

    /// A normalized value in the range `[0, 1]` that controls the horizontal
    /// split position of the mosaic effect.
    var offset: Double

    func body(content: Content) -> some View {
        content.layerEffect(shader(), maxSampleOffset: .zero)
    }

    /// Creates a shader for the current configuration.
    ///
    /// The `scale` parameter determines the coarseness of the mosaic effect
    /// when it is enabled. When the effect is disabled, a value of `1.0` is
    /// used so that the image is rendered without visible pixelation.
    ///
    /// - Returns: A configured `Shader` instance.
    private func shader() -> Shader {
        let scale = isOn ? 10.0 : 1.0
        let function = ShaderFunction(library: .module, name: "RealTimeMosicShader::main")
        return function(.boundingRect, .float(scale), .float(offset))
    }
}

#Preview {
    RealTimeMosicScreen()
}
