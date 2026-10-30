import MyToyboxCore
import SwiftUI

// MARK: - RectangleAnimationScreen

/// A screen that displays thousands of animated rectangles
/// which appear, grow, move, shrink, and disappear over time.
/// The animation is frame-driven using `TimelineView` and rendered via `Canvas`.
@Metadata(title: .screenRectangleAnimationTitle, description: .screenRectangleAnimationDescription, tags: [.animation])
public struct RectangleAnimationScreen: View {
    public init() {}

    @StateObject private var viewModel = ViewModel()

    public var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let rects = viewModel.rects
                    for rect in rects {
                        rect.update(size: size)
                        let path = Path { path in
                            let rectSize = CGSize(
                                width: rect.currentWidth,
                                height: rect.currentHeight
                            )
                            let rectOrigin = CGPoint(
                                x: rect.currentX - rect.currentWidth / 2,
                                y: rect.currentY - rect.currentHeight / 2
                            )
                            path.addRect(CGRect(origin: rectOrigin, size: rectSize))
                        }
                        context.fill(path, with: .color(rect.currentColor))
                    }
                }
                .onChange(of: timeline.date) { _, _ in
                    viewModel.updateRects()
                }
            }
            .task(id: geometry.size) {
                await setup(size: geometry.size)
            }
            .background(Color(red: 0.137, green: 0.137, blue: 0.137))
            .backgroundExtensionEffect()
        }
    }

    /// Lays out the rectangles for the given size.
    ///
    /// The first layout runs immediately. Subsequent layouts are debounced so that
    /// a live resize (e.g. folding / unfolding the device) does not rerun the
    /// expensive placement on every frame; the task is cancelled when the size
    /// changes again before the delay elapses.
    private func setup(size: CGSize) async {
        guard size.width > 0, size.height > 0 else { return }
        if !viewModel.rects.isEmpty {
            do {
                try await Task.sleep(for: .milliseconds(150))
            } catch {
                return
            }
        }
        viewModel.setup(size: size)
    }
}

#Preview {
    RectangleAnimationScreen()
}
