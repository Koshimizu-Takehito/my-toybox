import MyToyboxCore
import SwiftUI

// MARK: - CustomGridItem

nonisolated enum CustomGridItem: LayoutValueKey, Hashable {
    enum Bar: Hashable {
        case vertical
        case horizontal
    }

    case cell
    case bar(Bar)
    static let defaultValue: Self = .cell
}

// MARK: - LayoutProtocolSampleScreen

@Metadata(title: .screenLayoutProtocolSampleTitle, description: .screenLayoutProtocolSampleDescription, tags: [.layout])
public struct LayoutProtocolSampleScreen: View {
    public init() {}

    @State private var value: (column: Double, numOfItems: Double) = (5, 25)
    private var column: Int { Int(value.column) }
    private var numOfItems: Int { Int(value.numOfItems) }

    private var numOfVSpace: Int {
        (numOfItems / column) * (column - 1) + (numOfItems % column)
    }

    private var numOfHSpace: Int {
        (numOfItems / column) * column - (numOfItems % column == 0 ? column : 0)
    }

    public var body: some View {
        VStack {
            Spacer()
            Slider(
                value: $value.column,
                in: 5 ... 10
            )
            Slider(
                value: $value.numOfItems,
                in: 25 ... 100
            )
        }
        .background {
            CustomGridLayout(column: column) {
                ForEach(Array(0 ..< numOfItems), id: \.self) { _ in
                    Color.cyan
                        .mask { RoundedRectangle(cornerRadius: 4.0) }
                        .layoutValue(key: CustomGridItem.self, value: .cell)
                }
                ForEach(Array(0 ..< numOfVSpace), id: \.self) { _ in
                    Color.mint.opacity(0.7)
                        .mask { RoundedRectangle(cornerRadius: 4.0) }
                        .layoutValue(key: CustomGridItem.self, value: .bar(.vertical))
                }
                ForEach(Array(0 ..< numOfHSpace), id: \.self) { _ in
                    Color.pink.opacity(0.4)
                        .mask { RoundedRectangle(cornerRadius: 4.0) }
                        .layoutValue(key: CustomGridItem.self, value: .bar(.horizontal))
                }
            }
        }
        .padding()
    }
}

// MARK: - CustomGridLayout

struct CustomGridLayout: Layout {
    var column: Int

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let edge = min(proposal.width ?? 0, proposal.height ?? 0)
        let cellCount = subviews.count(where: { $0[CustomGridItem.self] == .cell })
        let (quotient, remainder) = cellCount.quotientAndRemainder(dividingBy: column)
        let row = quotient + (remainder == 0 ? 0 : 1)
        let ratio = (CGFloat(row) / CGFloat(column))
        return CGSize(width: edge, height: max(ratio, 1) * edge)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let space = min(bounds.width, bounds.height) * (8.0 / 360.0)
        let edge = (min(bounds.width, bounds.height) - CGFloat(column - 1) * space) / CGFloat(column)
        var count = (cell: 0, vertical: 0, horizontal: 0)
        for index in subviews.indices {
            let subview = subviews[index]
            let item = subview[CustomGridItem.self]
            switch item {
            case .cell:
                var point = bounds.origin
                point.x += CGFloat(count.cell % column) * (edge + space)
                point.y += CGFloat(count.cell / column) * (edge + space)
                subview.place(at: point, proposal: .init(width: edge, height: edge))
                count.cell += 1

            case .bar(.vertical):
                var point = bounds.origin
                point.x += edge + CGFloat(count.vertical % (column - 1)) * (edge + space) + 0.2 * space
                point.y += CGFloat(count.vertical / (column - 1)) * (edge + space)
                subview.place(at: point, proposal: .init(width: 0.6 * space, height: edge))
                count.vertical += 1

            case .bar(.horizontal):
                var point = bounds.origin
                point.x += CGFloat(count.horizontal % column) * (edge + space)
                point.y += edge + CGFloat(count.horizontal / column) * (edge + space) + 0.2 * space
                subview.place(at: point, proposal: .init(width: edge, height: 0.6 * space))
                count.horizontal += 1
            }
        }
    }
}

#Preview {
    LayoutProtocolSampleScreen()
}
