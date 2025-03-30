import SwiftUI

// MARK: - RectangleAnimationScreen

/// A screen that displays thousands of animated rectangles
/// which appear, grow, move, shrink, and disappear over time.
/// The animation is frame-driven using `TimelineView` and rendered via `Canvas`.
struct RectangleAnimationScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas {context, size in
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
            .onAppear {
                viewModel.setup(size: geometry.size)
            }
            .id(geometry.size)
            .background(Color(red: 0.137, green: 0.137, blue: 0.137))
            .ignoresSafeArea()
        }
    }
}

#Preview {
    RectangleAnimationScreen()
}
