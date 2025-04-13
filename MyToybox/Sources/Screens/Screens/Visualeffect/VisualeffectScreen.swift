import SwiftUI

struct VisualeffectScreen: View {
    var body: some View {
        GeometryReader { geometry in
            let scrollViewFrame = geometry.frame(in: .local)
            ScrollView {
                ForEach(0..<100) { offset in
                    RowContent(offset: offset, scrollViewFrame: scrollViewFrame)
                        .frame(height: scrollViewFrame.height / 8.0)
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct RowContent: View {
    let offset: Int
    let scrollViewFrame: CGRect
    @State var zIndex: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
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
                    .hueRotation(.degrees(frame.origin.y / 5))
                    .scaleEffect(max(1 + distance / 1000, 0))
                    .offset(y: distance1 < 0 ? -distance : distance)
                    .brightness(distance1 < 0 ? -distance / 500 : -distance / 200)
            }
    }
}

#Preview {
    VisualeffectScreen()
}
