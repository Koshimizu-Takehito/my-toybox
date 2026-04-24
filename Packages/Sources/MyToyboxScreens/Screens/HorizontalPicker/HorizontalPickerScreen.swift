import SwiftUI

// MARK: - HorizontalPickerScreen

/// A demo screen showcasing a horizontal 3D-style picker built with `HPicker`.
/// Users can scroll through numbered items, and the currently selected item is highlighted.
@Metadata(title: .screenHorizontalPickerTitle, description: .screenHorizontalPickerDescription, tags: [.layout])
struct HorizontalPickerScreen: View {
    @State private var selection: Int?
    let items = Array(0 ..< 20)

    var body: some View {
        HPicker(items: items, selection: $selection, numberOfDisplays: 9) { item in
            let isSelected = item == selection
            ItemView(item: item, isSelected: isSelected)
        }
    }
}

// MARK: - HPicker

/// A horizontally scrolling picker view with 3D-style rotation and center selection.
///
/// Items are displayed in a horizontal scroll view and rotate based on their distance from the center.
/// The item closest to the center is treated as selected, and tapping an item scrolls it into the center.
///
/// - Parameters:
///   - items: The collection of selectable values.
///   - selection: A binding to the currently selected value.
///   - numberOfDisplays: Approximate number of visible items (default is 7).
///   - content: A view builder for rendering each item.
struct HPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    private var items: [SelectionValue]
    private var numberOfDisplays: Int
    private var content: (SelectionValue) -> Content

    @Binding private var selection: SelectionValue?
    @State private var scrollOffset: Double = 0
    @State private var itemWidth: Double = 100.0

    init(
        items: [SelectionValue],
        selection: Binding<SelectionValue?>,
        numberOfDisplays: Int = 7,
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
                                .clipShape(.rect(cornerRadius: 4))
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
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
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
            .overlay {
                // Frame outline for the centered (selected) item
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255), lineWidth: 4)
                    .scaledToFit()
                    .shadow(radius: 2, x: 0, y: 2)
            }
            .onChange(of: widthPerItem, initial: true) { _, newValue in
                itemWidth = newValue
            }
        }
        .frame(height: itemWidth)
        .sensoryFeedback(trigger: selection) { _, _ in
            .selection
        }
    }
}

// MARK: - ItemView

/// A view representing a selectable item in the horizontal picker.
///
/// Highlights the selected item with bold yellow text.
private struct ItemView: View {
    var item: Int
    var isSelected: Bool

    var body: some View {
        Rectangle()
            .foregroundStyle(.blue)
            .overlay {
                Text(verbatim: "\(item)")
                    .font(.title)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .yellow : .white)
            }
    }
}

#Preview {
    HorizontalPickerScreen()
}
