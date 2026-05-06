import MyToyboxCore
import SwiftUI

struct FlowLayout: Layout {
    var vSpacing: CGFloat = 8.0
    var hSpacing: CGFloat = 8.0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let proposalWidth = proposal.width ?? .zero
        var remainWidth = proposalWidth - hSpacing
        var currentHeight = CGFloat.zero
        var totalSize = CGSize.zero
        for subview in subviews {
            let size = subview.sizeThatFits(.init(width: proposalWidth - 2 * hSpacing, height: .infinity))
            if remainWidth - (size.width + hSpacing) < 0 {
                totalSize.height += currentHeight
                remainWidth = proposalWidth - hSpacing
                currentHeight = .zero
            }
            remainWidth -= size.width + hSpacing
            currentHeight = max(size.height + vSpacing, currentHeight)
        }
        totalSize.height += currentHeight + vSpacing
        totalSize.width = proposalWidth
        return totalSize
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var offset = CGPoint.zero
        offset.y += vSpacing
        offset.x += hSpacing
        var remainWidth = bounds.width
        var currentHeight = CGFloat.zero
        for subview in subviews {
            let size = subview.sizeThatFits(.init(width: bounds.width - 2 * hSpacing, height: .infinity))
            if remainWidth - (size.width + hSpacing) < 0 {
                offset.y += currentHeight + vSpacing
                offset.x = hSpacing
                currentHeight = .zero
                remainWidth = (bounds.width - hSpacing)
            }
            let point = CGPoint(x: bounds.origin.x + offset.x, y: bounds.origin.y + offset.y)
            subview.place(at: point, proposal: .init(size))
            offset.x += size.width + hSpacing
            remainWidth -= size.width + hSpacing
            currentHeight = max(size.height, currentHeight)
        }
    }
}
