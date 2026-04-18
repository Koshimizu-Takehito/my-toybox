import SwiftUI

// MARK: - LostRowAnimationScreen

@Metadata(title: "Lost Row Animation", description: "ScrollView + LazyVStack アニメーション", tags: [.animation])
struct LostRowAnimationScreen: View {
    @State private var item: [Item] = .samples()
    @State private var show = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(item.indices, id: \.self) { index in
                    let offset = Double(min(index, 20) + 1)
                    VStack(spacing: 0) {
                        RowContent(item: item[index], index: index)
                        Divider()
                    }
                    .padding(.leading, 20)
                    .offset(y: show ? 0 : offset * 50)
                    .opacity(show ? 1 : 0)
                    .animation(.spring(duration: offset * 0.13), value: show)
                }
            }
        }
        .scrollIndicators(.hidden)
        .task {
            await fetch()
        }
        .refreshable {
            await fetch()
        }
    }

    func fetch() {
        show = false
        Task.detached {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            Task { @MainActor in
                item = .samples()
                show = true
            }
        }
    }
}

// MARK: - RowContent

private struct RowContent: View {
    let item: Item
    let index: Int

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Circle()
                    .foregroundStyle(icon)
                    .frame(width: 40)
                VStack(alignment: .leading) {
                    Text(item.code)
                        .font(.headline)
                    Text(item.name)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(item.price)
                    .font(.headline.monospacedDigit())
            }
            .foregroundStyle(.foreground)
            .padding()
        }
    }

    var icon: some ShapeStyle {
        let colorss = [[Color]].colors
        let colors = colorss[index % colorss.count]
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Item

private struct Item: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let price: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
        self.price = "$\(Int.random(in: 30 ..< 999))"
    }
}

extension [Item] {
    static func samples() -> Self {
        [
            Item(code: "MFST", name: "マイクロソフト"),
            Item(code: "AAPL", name: "アップル"),
            Item(code: "NVDA", name: "エヌビディア"),
            Item(code: "AMZN", name: "アマゾン・ドット・コム"),
            Item(code: "META", name: "メタ・プラットフォームズ"),
            Item(code: "GOOG", name: "アルファベット"),
            Item(code: "BRK", name: "バークシャー・ハサウェイ"),
            Item(code: "LLY", name: "イーライリリー"),
            Item(code: "AVGO", name: "ブロードコム"),
            Item(code: "JPM", name: "JPモルガン・チェース・アンド・カンパニー"),
        ]
    }
}

private extension [[Color]] {
    static let colors: [[Color]] = [
        [.orange, .pink],
        [.mint, .green],
        [.cyan, .blue],
        [.purple, .pink],
        [.purple, .orange],
        [.cyan, .mint],
        [.yellow, .orange],
        [.red, .blue],
    ]
}

#Preview {
    LostRowAnimationScreen()
}
