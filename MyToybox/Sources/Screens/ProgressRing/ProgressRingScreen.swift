import SwiftUI

/// The main view that displays two animated progress rings side by side.
/// Each ring shows the same progress value but uses a different text style (`Text1` and `Text2`).
/// There's also a control panel overlay for starting, pausing, and resetting the progress.
struct ProgressRingScreen: View {
    /// A view model that tracks and animates the progress value.
    @State var viewModel = ProgressRingViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Group {
                        // First progress ring uses Text1 for the percentage display.
                        ProgressRing(value: viewModel.progress, text: Text1.init)

                        // Second progress ring uses Text2 for the percentage display.
                        ProgressRing(value: viewModel.progress, text: Text2.init)
                    }
                    .scaledToFit()
                    .padding()
                }
                .frame(width: geometry.size.width * 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // A floating control panel with "Start", "Pause/Resume", and "Reset" actions.
                ProgressControl(viewModel: viewModel)
                    .fixedSize()
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .padding()
            }
        }
        .background {
            // A thin red rectangle for a simple background style
            Rectangle()
                .fill(Color.red)
                .frame(width: 2)
                .ignoresSafeArea()
        }
    }
}

/// A simple control panel view for managing the progress state.
/// It provides buttons to Start, Pause/Resume, and Reset the progress.
private struct ProgressControl: View {
    var viewModel: ProgressRingViewModel

    var body: some View {
        HStack(spacing: 12) {
            let canStart = viewModel.progress <= 0 || viewModel.progress >= 1
            let isPaused = viewModel.isPaused
            let canResume = (!canStart && isPaused)

            // Start / Pause / Resume Button
            Button {
                canStart ? viewModel.start() : isPaused ? viewModel.resume() : viewModel.pause()
            } label: {
                ZStack {
                    // A hidden label to reserve layout space so the button won't resize when toggling text.
                    PlaceholderLabel()
                    // Start or Reset
                    Label(action: canStart ? .start : canResume ? .resume : .pause)
                }
            }

            Divider()

            // Reset Button
            Button {
                viewModel.reset()
            } label: {
                ZStack {
                    // A hidden label to reserve layout space so the button won't resize when toggling text.
                    PlaceholderLabel()
                    // Start or Reset
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

/// A customizable circular progress ring that animates its trim value based on `value`.
/// - `value` is clamped to 0.0...1.0
/// - `text` is a ViewBuilder that receives the current progress value (0.0...1.0) and returns any View to overlay on the ring.
private struct ProgressRing<ProgressText: View>: Animatable {
    /// The current progress value (0.0 to 1.0).
    var value = 0.0

    /// A closure that creates a text (or any View) based on the current progress.
    var text: (Double) -> ProgressText

    /// Required property for SwiftUI to animate `value`.
    /// Ensures `value` always stays within the valid range [0,1].
    var animatableData: Double {
        get { max(min(value, 1), 0) }
        set { value = max(min(newValue, 1), 0) }
    }

    /// Creates a `ProgressRing`.
    /// - Parameters:
    ///   - value: The initial progress value. Defaults to 0.0
    ///   - text: A ViewBuilder closure that renders text or any overlay content given the current progress.
    init(value: Double = 0.0, @ViewBuilder text: @escaping (Double) -> ProgressText) {
        self.value = value
        self.text = text
    }
}

/// The View conformance for `ProgressRing`.
/// - Renders two circles: a background circle and a trimmed circle to show progress.
/// - Applies a gradient fill for the progress circle, rotating it so it starts from the top.
extension ProgressRing: View {
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
                // Rotate so that 0% is at the top, not the trailing side
                .rotationEffect(.degrees(-90.0 + (360.0 * value)))
        }
        .overlay {
            // Overlaid text, shows the current progress value in any custom format
            text(value)
                .bold()
                .monospacedDigit()
                .fixedSize()
        }
    }
}

/// A simple text view that displays the progress as a percentage (e.g., "85%").
/// Uses an `HStack` with `.bottom` alignment plus extra padding on the percent sign.
/// This approach is simpler if you only need a baseline alignment and a consistent font size.
private struct Text1: View {
    var value = 0.0

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("\(Int(value * 100))")
                .font(.largeTitle)
            Text("%")
                // Shift the percent sign slightly downward to visually align with the number.
                .padding(.bottom, 5)
        }
    }
}

/// A more precise text view that uses `GeometryReader` to measure the actual width/height of the text.
/// The percent sign is then overlaid at a position calculated from the measured size.
///
/// - This approach allows the main numeric text to be easily centered or moved independently in the parent view,
///   and the "%" is placed relative to the number's actual dimensions.
/// - It also adapts better to varying font sizes (e.g., Dynamic Type).
private struct Text2: View {
    var value = 0.0

    var body: some View {
        Text("\(Int(value * 100))")
            .font(.largeTitle)
            .overlay {
                GeometryReader { geometry1 in
                    Text("%")
                        .hidden()  // Hidden placeholder to measure '%'
                        .overlay {
                            GeometryReader { geometry2 in
                                Text("%")
                                    // Place the visible '%' to the right edge of the number,
                                    // offset vertically by the hidden text's height minus a small tweak.
                                    .offset(
                                        x: geometry1.size.width,
                                        y: geometry2.size.height - 5
                                    )
                            }
                        }
                }
            }
    }
}

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

    fileprivate init(action: Action) {
        self = Label(action.title, systemImage: action.symbol)
    }
}

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
