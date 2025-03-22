import SwiftUI

struct InfiniteScrollScreen: View {
    private var items: [Int] = (1...5).map(\.self)
    @State private var numberOfDisplays = 5
    @State private var showsIndicator = false
    @State private var viewId = UUID()

    var body: some View {
        ZStack {
            InfiniteScrollView(items, numberOfDisplay: numberOfDisplays, spacing: spacing) { index in
                ItemView(number: index)
            }
            .frame(maxHeight: 300)
            .scrollIndicators(showsIndicator ? .visible : .hidden)

            VStack(alignment: .trailing, spacing: 16) {
                Stepper("Display Items", value: $numberOfDisplays, in: 1...10)
                Toggle("Shows Scroll Indicator", isOn: $showsIndicator)
                Button("Reset", action: reset)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal)
        }
        .id(viewId)
    }

    private var spacing: Double {
        8 * min(Double(items.count) / Double(numberOfDisplays), 2)
    }

    private func reset() {
        withAnimation {
            numberOfDisplays = 5
            showsIndicator = false
            viewId = UUID()
        }
    }
}

// MARK: - InfiniteScrollView

private struct InfiniteScrollView<Item: Hashable, Content: View>: View {
    private var items: [Item]
    private var numberOfDisplay: Int
    private var spacing: Double
    private var content: (Item) -> Content
    @State private var itemWidth: Double = 0.0
    @State private var containerWidth: Double = 0.0

    var body: some View {
        InfiniteUIScrollView.Representable(items, spacing: spacing) { item in
            content(item)
                .frame(width: itemWidth, height: itemWidth)
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { width in
            containerWidth = width
            updateItemSize()
        }
        .onChange(of: numberOfDisplay, initial: false) { _, newValue in
            updateItemSize()
        }
        .frame(height: itemWidth)
    }

    private func updateItemSize() {
        let count = Double(max(numberOfDisplay, 1))
        self.itemWidth = (containerWidth - (count + 1) * spacing) / count
    }
}

extension InfiniteScrollView {
    init(_ items: [Item], numberOfDisplay: Int, spacing: Double = 16.0, @ViewBuilder content: @escaping (Item) -> Content) {
        self.init(items: items, numberOfDisplay: numberOfDisplay, spacing: spacing, content: content)
    }
}

// MARK: - UIViewRepresentable

private extension InfiniteUIScrollView {
    @MainActor
    struct Representable<Item: Hashable, Content: View>: UIViewRepresentable {
        private var items: [Item]
        private var spacing: Double
        private var content: (Item) -> Content

        func makeUIView(context: Context) -> InfiniteUIScrollView {
            InfiniteUIScrollView()
        }

        func updateUIView(_ view: InfiniteUIScrollView, context: Context) {
            let environment = context.environment
            view.showsHorizontalScrollIndicator = environment.horizontalScrollIndicatorVisibility == .visible
            view.contentBuilder = {
                UIHostingConfiguration(content: makeView)
                    .margins(.all, .zero)
                    .makeContentView()
            }
        }

        @ViewBuilder
        private func makeView() -> some View {
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: spacing, height: 0)
                HStack(spacing: spacing) {
                    ForEach(items, id: \.self) { items in
                        self.content(items)
                    }
                }
            }
        }
    }
}

extension InfiniteUIScrollView.Representable {
    init(_ items: [Item], spacing: Double, @ViewBuilder content: @escaping (Item) -> Content) {
        self.init(items: items, spacing: spacing, content: content)
    }
}

// MARK: - UIScrollView

private final class InfiniteUIScrollView: UIScrollView {
    var contentBuilder: (() -> UIView)!
    private var visibleContents = [UIView]()
    private let containerView = UIView()

    override var frame: CGRect {
        didSet {
            if frame != .zero {
                visibleContents.forEach { $0.removeFromSuperview() }
                visibleContents.removeAll(keepingCapacity: true)
                let content = makeContent()
                containerView.addSubview(content)
                containerView.frame = CGRect(origin: .zero, size: contentSize)
                visibleContents.append(content)
                contentSize.height = frame.height
                contentSize.width = max(content.bounds.width, bounds.width) * 3
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.containerView.isUserInteractionEnabled = false
        self.addSubview(containerView)
        self.contentSize = frame.size
    }

    // MARK: - レイアウト

    /// スクロール位置などが変化するたびに自動的に呼ばれる
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterIfNecessary()

        let visibleBounds = convert(bounds, to: containerView)
        let minimumVisibleX = visibleBounds.minX
        let maximumVisibleX = visibleBounds.maxX
        tileContents(fromMinX: minimumVisibleX, toMaxX: maximumVisibleX)
    }

    /// スクロールが大きく中央からずれた時に、コンテンツオフセットを中央付近へ補正して無限に見えるようにする
    private func recenterIfNecessary() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.width) / 2.0
        let distanceFromCenter = abs(currentOffset.x - centerOffsetX)
        // 中心から一定以上離れた場合、スクロール位置を中央付近へ戻す
        if distanceFromCenter > (contentWidth / 4.0) {
            contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
            // 見かけ上同じ位置にあるようにするため、View自体の座標をスクロール分だけ補正
            for content in visibleContents {
                // スーパービュー（InfiniteScrollView）の座標系でViewの中心を取得
                var center = containerView.convert(content.center, to: self)
                // オフセット差分だけ x 座標を移動
                center.x += (centerOffsetX - currentOffset.x)
                // 補正した座標をViewコンテナの座標系に変換し直して設定
                content.center = convert(center, to: containerView)
            }
        }
    }

    // MARK: - コンテンツの配置

    /// containerView に追加すべき View を生成する
    private func makeContent() -> UIView {
        let view = contentBuilder()
        view.sizeToFit()
        return view
    }

    /// 指定した位置（rightEdge）に新規Viewを右側に追加し、そのViewの右端座標を返す
    @discardableResult
    private func placeNewContentOnRight(_ rightEdge: CGFloat) -> CGFloat {
        let content = makeContent()
        containerView.addSubview(content)
        visibleContents.append(content)

        var frame = content.frame
        frame.origin.x = rightEdge
        // コンテナの下端に揃えて配置
        frame.origin.y = containerView.bounds.height - frame.size.height
        content.frame = frame

        return frame.maxX
    }

    /// 指定した位置（leftEdge）に新規Viewを左側に追加し、そのViewの左端座標を返す
    @discardableResult
    private func placeNewContentOnLeft(_ leftEdge: CGFloat) -> CGFloat {
        let content = makeContent()
        containerView.addSubview(content)
        visibleContents.insert(content, at: 0)

        var frame = content.frame
        frame.origin.x = leftEdge - frame.size.width
        // コンテナの下端に揃えて配置
        frame.origin.y = containerView.bounds.height - frame.size.height
        content.frame = frame

        return frame.minX
    }

    /// 現在の可視領域 [minX, maxX] に合わせてタイル状に並べる
    private func tileContents(fromMinX minX: CGFloat, toMaxX maxX: CGFloat) {
        // 初回呼び出し時にViewが1つも無い場合、強制的に右端に1つ作っておく
        if visibleContents.isEmpty {
            placeNewContentOnRight(minX)
        }
        // 右側にViewが足りなければ追加
        var lastContent = visibleContents.last!
        var rightEdge = lastContent.frame.maxX
        while rightEdge < maxX {
            rightEdge = placeNewContentOnRight(rightEdge)
        }
        // 左側にViewが足りなければ追加
        var firstContent = visibleContents.first!
        var leftEdge = firstContent.frame.minX
        while leftEdge > minX {
            leftEdge = placeNewContentOnLeft(leftEdge)
        }
        // 画面から外れた右側のViewを削除
        lastContent = visibleContents.last!
        while lastContent.frame.origin.x > maxX {
            lastContent.removeFromSuperview()
            visibleContents.removeLast()
            guard let newLast = visibleContents.last else { break }
            lastContent = newLast
        }
        // 画面から外れた左側のViewを削除
        firstContent = visibleContents.first!
        while firstContent.frame.maxX < minX {
            firstContent.removeFromSuperview()
            visibleContents.removeFirst()
            guard let newFirst = visibleContents.first else { break }
            firstContent = newFirst
        }
    }
}

// MARK: - ItemView

private struct ItemView: View {
    var number: Int

    var body: some View {
        Color.blue
            .overlay {
                Text("\(number)")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .padding(4)
            }
            .clipShape(.rect(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview("InfiniteScrollView") {
    let numbers = (1...5).map(\.self)
    InfiniteScrollView(numbers, numberOfDisplay: 5) {
        ItemView(number: $0)
    }
    .scrollIndicators(.visible)
}
