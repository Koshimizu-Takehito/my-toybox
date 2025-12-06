import SwiftUI

actor HomeIconRepository {
    /// A fixed pool of SF Symbol names used for the demo.
    private static let symbols: [String] = [
        "pencil", "trash", "folder", "camera",
        "photo", "clock", "arrow.right.circle.fill", "plus",
        "multiply", "square.and.arrow.up", "bubble.left", "heart",
        "person", "bolt", "star", "exclamationmark.triangle",
    ]

    /// A palette that roughly matches the color variety on the real Home Screen.
    private static let colors: [Color] = [
        .black, .gray, .red, .green, .blue, .orange, .cyan,
        .brown, .mint, .yellow, .pink, .indigo, .purple,
    ]

    private var items: [HomeIcon]?

    func fetch(numberOfChunk: Int) -> [[HomeIcon]] {
        let items = fetch()
        let (quotient, _) = items.count.quotientAndRemainder(dividingBy: numberOfChunk)
        var result = [[HomeIcon]]()
        for i in 0..<quotient {
            result.append(Array(items[i * numberOfChunk..<(i + 1) * numberOfChunk]))
        }
        let r = Array(items[quotient * numberOfChunk..<items.count])
        if !r.isEmpty {
            result.append(r)
        }
        return result
    }

    func fetch() -> [HomeIcon] {
        if let items {
            return items
        }
        let symbols = Self.symbols
        let colors = symbols.indices.lazy.map { i in
            Self.colors[i % Self.colors.count]
        }
        let items = zip(symbols, colors).map(HomeIcon.init(symbol:color:))
        self.items = items

        return items
    }
}
