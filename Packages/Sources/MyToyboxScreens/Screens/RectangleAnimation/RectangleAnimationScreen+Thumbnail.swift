import SwiftUI

extension RectangleAnimationScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        Thumbnail(time: time)
    }

    private struct Thumbnail: View {
        @StateObject private var viewModel = ViewModel()
        var time: TimeInterval

        var body: some View {
            GeometryReader { geometry in
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
                .onChange(of: time) { _, _ in
                    viewModel.updateRects()
                }
                .onAppear {
                    viewModel.setup(size: geometry.size)
                }
                .id(geometry.size)
                .background(Color(red: 0.137, green: 0.137, blue: 0.137).gradient)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
