import SwiftUI

// MARK: - SpiralLayoutDemoScreen

/// A demonstration screen showcasing a custom spiral layout.
/// Users can increase or decrease the number of cells, which are colored rectangles arranged in a spiral pattern.
/// The layout dynamically adapts to the number of cells using the Stepper control.
struct SpiralLayoutDemoScreen: View {
    @State private var count: Int = 1

    var body: some View {
        VStack {
            Spacer()
            SpiralLayout {
                ForEach(0..<count, id: \.self) { index in
                    ColorCell(index: index)
                }
            }
            Spacer()
            Stepper(value: $count.animation(), in: 1...21) {
                Text("Count \(count.formatted())")
            }
        }
        .padding()
        .font(.title2)
        .contentTransition(.numericText())
    }
}

// MARK: - ColorCell

/// Represents a single colored cell in the spiral layout.
/// The color is determined by the cell's index to ensure a visually appealing pattern.
private struct ColorCell: View {
    /// The position of the cell in the spiral.
    var index: Int

    var body: some View {
        Text(index.formatted())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(itemColor(for: index))
    }

    /// Returns a color based on the index, generating visually distinct hues.
    private func itemColor(for index: Int) -> Color {
        let hue = Double((index * 210) % 360) / 360
        return Color(hue: hue, saturation: 0.5, brightness: 1.0)
    }
}

// MARK: - SpiralLayout

/// A custom SwiftUI layout that arranges its children in a spiral pattern.
/// Each cell is a rectangle, and the layout algorithm ensures that the rectangles are placed in a way that visually simulates a spiral,
/// with each cell occupying equal area as much as possible.
struct SpiralLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Ensure the layout is square, constrained by the smallest side.
        let size = CGSize(width: proposal.width ?? .zero, height: proposal.height ?? .zero)
        let side = min(size.width, size.height)
        return CGSize(width: side, height: side)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        // No subviews to arrange.
        if subviews.count <= 0 {
            return
        }

        // Calculate the number of "rows" needed for the spiral.
        let rowCount = 1 + 2 * ((subviews.count - 1 + 3) / 4)
        let size = CGSize(width: proposal.width ?? .zero, height: proposal.height ?? .zero)
        let side = min(size.width, size.height)
        let cellSide = side / CGFloat(rowCount)

        // Place the central cell.
        subviews[0].place(
            at: bounds.center - cellSide / 2,
            proposal: .init(width: cellSide, height: cellSide)
        )

        // Place remaining cells in a spiral path, alternating direction and length.
        for index in 1..<subviews.count {
            let layer = (index - 1) / 4
            let direction = index % 4
            let longSide = 2 * (cellSide + cellSide * CGFloat(layer))

            switch direction {
            case 1:
                // Right horizontal extension
                subviews[index].place(
                    at: CGPoint(
                        x: -(cellSide * CGFloat(layer)),
                        y: cellSide + (cellSide * CGFloat(layer))
                    ) + (bounds.center - cellSide / 2),
                    proposal: .init(width: longSide, height: cellSide)
                )
            case 2:
                // Up vertical extension
                subviews[index].place(
                    at: CGPoint(
                        x: cellSide + cellSide * CGFloat(layer),
                        y: -cellSide * CGFloat(layer + 1)
                    ) + (bounds.center - cellSide / 2),
                    proposal: .init(width: cellSide, height: longSide)
                )
            case 3:
                // Left horizontal extension
                subviews[index].place(
                    at: CGPoint(
                        x: -cellSide * CGFloat(layer + 1),
                        y: -cellSide * CGFloat(layer + 1)
                    ) + (bounds.center - cellSide / 2),
                    proposal: .init(width: longSide, height: cellSide)
                )
            default:
                // Down vertical extension
                subviews[index].place(
                    at: CGPoint(
                        x: -cellSide * CGFloat(layer + 1),
                        y: -cellSide * CGFloat(layer)
                    ) + (bounds.center - cellSide / 2),
                    proposal: .init(width: cellSide, height: longSide)
                )
            }
        }
    }
}

// MARK: - Utilities

nonisolated extension CGRect {
    /// Returns the center point of the rectangle.
    fileprivate var center: CGPoint { CGPoint(x: midX, y: midY) }
}

nonisolated extension CGPoint {
    fileprivate init(_ value: CGFloat) {
        self.init(x: value, y: value)
    }

    /// Adds two CGPoint values.
    fileprivate static func + (_ lhs: Self, _ rhs: Self) -> Self {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Subtracts two CGPoint values.
    fileprivate static func - (_ lhs: Self, _ rhs: Self) -> Self {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Subtracts a CGFloat value from a CGPoint (on both axes).
    fileprivate static func - (_ lhs: Self, _ rhs: CGFloat) -> Self {
        lhs - .init(rhs)
    }

    /// Subtracts a CGPoint from a CGFloat value, returning a CGPoint.
    fileprivate static func - (_ lhs: CGFloat, _ rhs: Self) -> Self {
        .init(lhs) - rhs
    }

    /// Divides a CGPoint by a CGFloat value.
    fileprivate static func / (_ lhs: Self, _ rhs: CGFloat) -> Self {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

// MARK: - Preview

#Preview {
    SpiralLayoutDemoScreen()
}
