import SwiftUI
// https://github.com/apple/sample-food-truck/blob/main/App/General/FlowLayout.swift

// MARK: - PickerFlowLayout

/// A layout that arranges subviews in a horizontal flow, wrapping
/// to new lines when they exceed the available width. Useful for
/// tag or chip pickers, flow-based grids, etc.
///
/// - `alignment`: Controls horizontal and vertical alignment within each row.
/// - `spacing`: Optional custom spacing between items; defaults to system spacing.
struct PickerFlowLayout: Layout {
    /// How to align items within their rows (e.g., .leading, .center, .trailing).
    var alignment: Alignment = .center

    /// Optional spacing between items. If `nil`, uses default `spacing` from the environment.
    var spacing: CGFloat?

    /// Computes the total size needed to fit all subviews, given a proposed size.
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let layout = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return layout.bounds
    }

    /// Positions each subview within the provided bounds, based on layout calculation.
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let layout = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )

        // Place each row of items
        for row in layout.rows {
            // Horizontal offset for the row, based on the chosen alignment
            let rowXOffset = (bounds.width - row.frame.width) * alignment.horizontal.percent

            // Position each item in this row
            for index in row.range {
                let x = rowXOffset
                    + row.frame.minX
                    + row.xOffsets[index - row.range.lowerBound]
                    + bounds.minX

                let viewSize = subviews[index].sizeThatFits(.unspecified)
                let yAlignmentOffset = (row.frame.height - viewSize.height) * alignment.vertical.percent
                let y = row.frame.minY + yAlignmentOffset + bounds.minY

                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: .unspecified
                )
            }
        }
    }

    // MARK: - FlowResult

    /// Internal helper that computes wrapping rows and overall bounds.
    struct FlowResult {
        /// The combined bounding size of all rows.
        var bounds: CGSize = .zero

        /// Details for each computed row.
        var rows: [Row] = []

        /// Represents one horizontal row of items.
        struct Row {
            /// The index range of subviews in this row.
            var range: Range<Int>

            /// The x-offsets (within the row) for each item.
            var xOffsets: [Double]

            /// The frame rectangle of this row.
            var frame: CGRect
        }

        /// Initializes layout calculation.
        ///
        /// - Parameters:
        ///   - in: Maximum width available per row.
        ///   - subviews: The views to layout.
        ///   - alignment: How to align within each row.
        ///   - spacing: Optional custom spacing between items.
        init(
            in maxPossibleWidth: Double,
            subviews: Subviews,
            alignment: Alignment,
            spacing: CGFloat?
        ) {
            var itemsInRow = 0
            var remainingWidth = maxPossibleWidth.isFinite ? maxPossibleWidth : .greatestFiniteMagnitude
            var rowMinY = 0.0
            var rowHeight = 0.0
            var xOffsets: [Double] = []

            for (index, subview) in zip(subviews.indices, subviews) {
                let size = subview.sizeThatFits(.unspecified)
                var spacingBeforeCurrent = spacingBefore(index: index)
                var widthWithSpacing = size.width + spacingBeforeCurrent

                // If this item doesn't fit, finalize the current row
                if index != 0 && widthWithSpacing > remainingWidth {
                    finalizeRow(at: index - 1)
                    spacingBeforeCurrent = spacingBefore(index: index)
                    widthWithSpacing = size.width + spacingBeforeCurrent
                }

                // Add to current row
                xOffsets.append(maxPossibleWidth - remainingWidth + spacingBeforeCurrent)
                remainingWidth -= widthWithSpacing
                rowHeight = max(rowHeight, size.height)
                itemsInRow += 1

                // If last item, finalize this row
                if index == subviews.count - 1 {
                    finalizeRow(at: index)
                }
            }

            // Helper: spacing before a given index
            func spacingBefore(index: Int) -> Double {
                guard itemsInRow > 0 else { return 0 }
                return spacing ?? subviews[index - 1]
                    .spacing
                    .distance(to: subviews[index].spacing, along: .horizontal)
            }

            // Finalizes a row ending at `lastIndex`.
            func finalizeRow(at lastIndex: Int) {
                let rowWidth = maxPossibleWidth - remainingWidth
                let startIndex = lastIndex - (itemsInRow - 1)

                rows.append(
                    Row(
                        range: startIndex..<lastIndex + 1,
                        xOffsets: xOffsets,
                        frame: CGRect(x: 0, y: rowMinY, width: rowWidth, height: rowHeight)
                    )
                )

                // Update overall bounds
                bounds.width = max(bounds.width, rowWidth)
                let verticalGap = spacing ?? ViewSpacing()
                    .distance(to: ViewSpacing(), along: .vertical)
                bounds.height += rowHeight + (rows.count > 1 ? verticalGap : 0)

                // Prepare for next row
                rowMinY += rowHeight + verticalGap
                itemsInRow = 0
                rowHeight = 0
                xOffsets.removeAll()
                remainingWidth = maxPossibleWidth
            }
        }
    }
}

// MARK: - Alignment Percentage Helpers

private extension HorizontalAlignment {
    /// Maps `.leading` → 0, `.center` → 0.5, `.trailing` → 1.0
    nonisolated var percent: Double {
        switch self {
        case .leading: return 0
        case .trailing: return 1
        default: return 0.5
        }
    }
}

private extension VerticalAlignment {
    /// Maps `.top` → 0, `.center` → 0.5, `.bottom` → 1.0
    nonisolated var percent: Double {
        switch self {
        case .top: return 0
        case .bottom: return 1
        default: return 0.5
        }
    }
}
