import SwiftUI

// MARK: - ProgressRingScreen

/// A screen demonstrating a circular progress ring with a slider and control panel.
/// Uses a `ProgressRingViewModel` to track and animate the progress state.
struct ProgressRingScreen: View {
    /// A view model that tracks and animates the progress value.
    @State var viewModel = ProgressRingViewModel()

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)
            VStack(spacing: 0) {
                rings(width: width)
                controls(width: width)
            }
        }
    }

    /// Creates a single `ProgressRing` that displays the current progress,
    /// using `ProgressText` to overlay the numeric percentage.
    ///
    /// - Parameter width: The smallest dimension of the available space.
    /// - Returns: A view containing the progress ring sized appropriately.
    private func rings(width: Double) -> some View {
        ProgressRing(value: viewModel.progress, text: ProgressText.init)
            .scaledToFit()
            .padding()
            .frame(width: width * 0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Renders a slider and control panel for managing the progress, adapting layout for various screen sizes.
    ///
    /// - Parameter width: The smallest dimension of the available space.
    /// - Returns: A view containing the slider and control panel in an adaptive layout.
    private func controls(width: Double) -> some View {
        ViewThatFits {
            // Horizontal layout for larger screens
            HStack {
                // Use the slider to manually set or pause progress.
                ProgressSlider(viewModel: viewModel)
                    .frame(minWidth: width * 0.5)
                    .padding()

                // A floating control panel with "Start", "Pause/Resume", and "Reset" actions.
                ProgressControl(viewModel: viewModel)
                    .fixedSize()
                    .padding()
            }
            // Vertical layout if horizontal space is constrained
            VStack {
                ProgressSlider(viewModel: viewModel)
                    .padding(.horizontal)

                // Let the control panel float to the bottom/trailing edge.
                ProgressControl(viewModel: viewModel)
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - ProgressSlider

/// A slider view for manually adjusting the progress value.
/// Pauses the animation while the slider is dragged, avoiding conflicts with ongoing animation.
private struct ProgressSlider: View {
    var viewModel: ProgressRingViewModel

    /// Binds to the `progress` property of the view model, pausing animation on user input.
    private var progressBinding: Binding<Double> {
        Binding {
            viewModel.progress
        } set: { newProgress in
            viewModel.pause()
            viewModel.progress = newProgress
        }
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Slider(value: progressBinding.animation(), in: 0...1)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - ProgressControl

/// A simple control panel for managing the progress state,
/// providing buttons to Start, Pause/Resume, or Reset.
private struct ProgressControl: View {
    var viewModel: ProgressRingViewModel

    var body: some View {
        HStack(spacing: 12) {
            let canStart = viewModel.progress <= 0 || viewModel.progress >= 1
            let isPaused = viewModel.isPaused
            let canResume = (!canStart && isPaused)

            // Start / Pause / Resume Button
            Button {
                canStart
                    ? viewModel.start()
                    : isPaused
                        ? viewModel.resume()
                        : viewModel.pause()
            } label: {
                ZStack {
                    // A hidden label to reserve layout space
                    // so the button won't resize when toggling text.
                    PlaceholderLabel()
                    Label(action: canStart ? .start : canResume ? .resume : .pause)
                }
            }

            Divider()

            // Reset Button
            Button {
                viewModel.reset()
            } label: {
                ZStack {
                    // A hidden label to reserve layout space
                    // so the button won't resize when toggling text.
                    PlaceholderLabel()
                    Label(action: .reset)
                }
            }
            .disabled(canStart)
        }
        .font(.body.bold())
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - ProgressRing

/// A customizable circular progress ring that animates its trim value based on `value`.
/// - `value` is clamped to 0.0...1.0
/// - `text` is a ViewBuilder that receives the current progress value (0.0...1.0) and returns any overlay View.
///
/// Conforms to `Animatable` so SwiftUI can smoothly animate changes to `value`.
private struct ProgressRing<ProgressText: View>: Animatable {

    /// The current progress value (0.0 to 1.0).
    var value = 0.0

    /// A closure that creates an overlay (e.g., text) based on the current progress.
    var text: (Double) -> ProgressText

    /// The property used by SwiftUI to animate `value`.
    /// This getter/setter enforces the valid range [0,1].
    var animatableData: Double {
        get { max(min(value, 1), 0) }
        set { value = max(min(newValue, 1), 0) }
    }

    /// Creates a `ProgressRing`.
    /// - Parameters:
    ///   - value: The initial progress value. Defaults to 0.0.
    ///   - text: A ViewBuilder closure that renders the overlay given the current progress.
    init(value: Double = 0.0, @ViewBuilder text: @escaping (Double) -> ProgressText) {
        self.value = value
        self.text = text
    }
}

extension ProgressRing: View {
    /// Draws a circular progress indicator with a background circle,
    /// a foreground arc showing the current progress,
    /// and an overlaid content view (e.g., progress text).
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(lineWidth: 15)
                .foregroundStyle(.gray.opacity(0.3))

            // Animated progress arc
            Circle()
                .trim(from: 0, to: value)
                .stroke(
                    style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                // Rotate so that 0% is at the top (not the trailing side).
                .rotationEffect(.degrees(-90.0 + (360.0 * value)))
        }
        .overlay {
            // Overlaid content, e.g., a text label with the current progress
            text(value)
                .bold()
                .monospacedDigit()
                .fixedSize()
        }
    }
}

// MARK: - ProgressText

/// A simple text view that displays the progress as a percentage, e.g., "85%".
/// Uses an `HStack` with `.bottom` alignment to keep the '%' sign lower than the number.
private struct ProgressText: View {
    /// The current progress value, from 0.0 to 1.0.
    /// Multiplied by 100 to display a percentage.
    var progressValue = 0.0  // renamed from `value` for clarity (optional)

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("\(Int(progressValue * 100))")
                .font(.largeTitle)
            Text("%")
                // Shift the percent sign slightly downward to visually align with the number
                .padding(.bottom, 5)
        }
    }
}

// MARK: - Label.Action

extension Label<Text, Image> {
    fileprivate enum Action: CaseIterable {
        case start
        case reset
        case resume
        case pause

        var title: String {
            switch self {
            case .start:
                return "Start"
            case .reset:
                return "Reset"
            case .resume:
                return "Resume"
            case .pause:
                return "Pause"
            }
        }

        var symbol: String {
            switch self {
            case .start:
                return "play"
            case .reset:
                return "arrow.trianglehead.counterclockwise"
            case .resume:
                return "forward.frame"
            case .pause:
                return "pause"
            }
        }
    }

    /// Creates a `Label` with a title and system image based on the given action type.
    fileprivate init(action: Action) {
        self = Label(action.title, systemImage: action.symbol)
    }
}

// MARK: - PlaceholderLabel

/// A hidden label to reserve layout space so the button won't resize when toggling text.
private struct PlaceholderLabel: View {
    var body: some View {
        ZStack {
            ForEach(Label.Action.allCases, id: \.self) { action in
                Label(action: action)
            }
        }
        .hidden()
    }
}

#Preview {
    ProgressRingScreen()
}
