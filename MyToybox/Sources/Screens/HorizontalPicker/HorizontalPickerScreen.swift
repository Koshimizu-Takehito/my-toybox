import SwiftUI

struct HorizontalPickerScreen: View {
    @State var selection: Int?
    let items = (0..<20).map(\.self)

    var body: some View {
        HPicker(items: items, selection: $selection, numberOfDisplays: 9) { item in
            let isSelected = item == selection
            ItemView(item: item, isSelected: isSelected)
        }
    }
}

struct HPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
    private var items: [SelectionValue]
    private var numberOfDisplays: Int
    private var content: (SelectionValue) -> Content
    @Binding private var selection: SelectionValue?
    @State private var contentOffset: Double = 0
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
            let numberOfDisplays = Double(numberOfDisplays) - 2
            let itemWidth = proxy.size.width / numberOfDisplays
            let margins = (proxy.size.width - itemWidth) / 2.0
            ScrollView(.horizontal) {
                ScrollViewReader { scrollView in
                    HStack(spacing: 0) {
                        ForEach(0..<items.count, id: \.self) { index in
                            let offset = (Double(index) - contentOffset / itemWidth)
                            let x0 = numberOfDisplays/2
                            let x1 = min(max(offset/x0, -6), 6) * .pi/3
                            let ε = 0.001
                            let x2 = min(max(x1, -(.pi/2 - ε)), (.pi/2 - ε))
                            let item = items[index]
                            content(item)
                                .frame(width: itemWidth, height: itemWidth)
                                .clipShape(.rect(cornerRadius: 4))
                                .rotation3DEffect(.radians(x2), axis: (0, 1, 0), perspective: 0)
                                .offset(x: -Double(offset) * itemWidth)
                                .offset(x: x0 * itemWidth * sin(x2))
                                .onGeometryChange(for: CGRect.self) {
                                    $0.frame(in: .scrollView)
                                } action: { frame in
                                    if abs(frame.origin.x) <= itemWidth/2.0 {
                                        selection = item
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        scrollView.scrollTo(index, anchor: .center)
                                    }
                                }
                                .allowsHitTesting(abs(x2) < 1)
                        }
                        .onChange(of: numberOfDisplays, initial: true) { _, displayItems in
                            if let selection, let index = items.firstIndex(where: { $0 ==  selection}) {
                                scrollView.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .scrollView)
                    } action: { frame in
                        contentOffset = -frame.origin.x
                    }
                }
            }
            .frame(height: itemWidth)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, margins)
            .mask {
                // LinearGradient
                let count = Int(numberOfDisplays)
                LinearGradient(
                    colors: [.clear] + Array(repeating: .black, count: count) + [.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .overlay {
                // Border of the currently selected item.
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 229/255, green: 229/255, blue: 234/255), lineWidth: 4)
                    .scaledToFit()
                    .shadow(radius: 2, x: 0, y: 2)
            }
            .onChange(of: itemWidth, initial: true) { _, itemWidth in
                self.itemWidth = itemWidth
            }
        }
        .frame(height: itemWidth)
        .sensoryFeedback(trigger: selection) { _, _ in
            .selection
        }
    }
}

private struct ItemView: View {
    var item: Int
    var isSelected: Bool

    var body: some View {
        Rectangle()
            .foregroundStyle(.blue)
            .overlay {
                Text("\(item)")
                    .font(.title)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .yellow : .white)
            }
    }
}

#Preview {
    HorizontalPickerScreen()
}
