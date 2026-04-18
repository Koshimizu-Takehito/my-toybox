import SwiftUI

extension VisualeffectScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let scrollViewFrame = geometry.frame(in: .local)
            ScrollView {
                VStack(spacing: 0.04 * size) {
                    ForEach(0 ..< 5) { offset in
                        ThumbnailRowContent(offset: offset, scrollViewFrame: scrollViewFrame)
                            .frame(height: scrollViewFrame.height / 8.0)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(true)
            .padding(0.08 * size)
        }
    }

    private struct ThumbnailRowContent: View {
        let offset: Int
        let scrollViewFrame: CGRect
        @State private var zIndex: Double = 0

        var body: some View {
            Capsule()
                .fill(.blue)
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .scrollView) } action: { newValue in
                    zIndex = min(newValue.minY, min(scrollViewFrame.midY - newValue.midY, 0))
                }
                .zIndex(zIndex * Double(offset))
                .visualEffect { content, proxy in
                    let frame = proxy.frame(in: .scrollView(axis: .vertical))
                    let distance1 = frame.minY
                    let distance2 = scrollViewFrame.maxY - frame.maxY
                    let distance = min(distance1, min(distance2, 0))
                    return content
                        .hueRotation(.degrees(2 * frame.origin.y))
                        .scaleEffect(max(1 + distance / 1000, 0))
                        .offset(y: distance1 < 0 ? -distance : distance)
                        .brightness(distance1 < 0 ? -distance / 500 : -distance / 200)
                }
        }
    }
}

#Preview {
    VisualeffectScreen.thumbnail
}
