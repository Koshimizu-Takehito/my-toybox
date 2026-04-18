import SwiftUI

extension HorizontalPickerScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        ThumbnailHPicker(items: Array(0 ..< 7), selection: .constant(2), numberOfDisplays: 7) { _ in
            Rectangle().foregroundStyle(Color.mint.gradient)
        }
    }

    private struct ThumbnailHPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
        private var items: [SelectionValue]
        private var numberOfDisplays: Int
        private var content: (SelectionValue) -> Content

        @Binding private var selection: SelectionValue?
        @State private var scrollOffset: Double = 0
        @State private var itemWidth: Double = 100.0

        init(
            items: [SelectionValue],
            selection: Binding<SelectionValue?>,
            numberOfDisplays: Int,
            @ViewBuilder content: @escaping (SelectionValue) -> Content
        ) {
            self.items = items
            self.numberOfDisplays = numberOfDisplays
            self.content = content
            _selection = selection
        }

        var body: some View {
            GeometryReader { proxy in
                // Calculate item width based on total width and number of displays
                let visibleCount = Double(numberOfDisplays) - 2
                let widthPerItem = proxy.size.width / visibleCount
                let sideMargin = (proxy.size.width - widthPerItem) / 2.0

                ScrollView(.horizontal) {
                    ScrollViewReader { scrollView in
                        HStack(spacing: 0) {
                            ForEach(0 ..< items.count, id: \.self) { index in
                                // Determine item's distance from the scroll center
                                let offset = (Double(index) - scrollOffset / widthPerItem)
                                // Convert offset to rotation angle
                                let rotationLimit = min(max(offset / (visibleCount / 2), -6), 6)
                                let angle = rotationLimit * .pi / 3
                                let clampedAngle = min(max(angle, -(.pi / 2 - 0.001)), .pi / 2 - 0.001)

                                let item = items[index]
                                content(item)
                                    .frame(width: widthPerItem, height: widthPerItem)
                                    .clipShape(.rect(cornerRadius: 1))
                                    .rotation3DEffect(.radians(clampedAngle), axis: (0, 1, 0), perspective: 0)
                                    .offset(x: -offset * widthPerItem)
                                    .offset(x: (visibleCount / 2) * widthPerItem * sin(clampedAngle))
                                    .onGeometryChange(for: CGRect.self) {
                                        $0.frame(in: .scrollView)
                                    } action: { frame in
                                        // Detect if this item is centered and set selection
                                        if abs(frame.origin.x) <= widthPerItem / 2 {
                                            selection = item
                                        }
                                    }
                                    .onTapGesture {
                                        // Scroll tapped item into center
                                        withAnimation {
                                            scrollView.scrollTo(index, anchor: .center)
                                        }
                                    }
                                    .allowsHitTesting(abs(clampedAngle) < 1)
                            }
                            .onChange(of: visibleCount, initial: true) { _, _ in
                                // Scroll selected item into center on mount
                                if let selection, let index = items.firstIndex(of: selection) {
                                    scrollView.scrollTo(index, anchor: .center)
                                }
                            }
                        }
                        .scrollTargetLayout()
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .scrollView)
                        } action: { frame in
                            scrollOffset = -frame.origin.x
                        }
                    }
                }
                .frame(height: widthPerItem)
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .contentMargins(.horizontal, sideMargin)
                .mask {
                    // Mask edge items with gradient for visual focus
                    let count = Int(visibleCount)
                    LinearGradient(
                        colors: [.clear] + Array(repeating: .black, count: count) + [.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .onChange(of: widthPerItem, initial: true) { _, newValue in
                    itemWidth = newValue
                }
            }
            .frame(height: itemWidth)
        }
    }
}
