import SwiftUI

struct RadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews _: Subviews, cache _: inout Void) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout Void) {
        let side = min(bounds.size.width, bounds.size.height)
        let angle = Double.pi / Double(subviews.count)
        let itemRadius = (side / 2.0) * sin(angle) / (1.0 + sin(angle))
        let ringRadius = (side / 2.0) * (1.0 + sin(angle)).rounded(.down)
        let step = Angle.radians(2.0 * angle).radians
        for (index, subview) in subviews.enumerated() {
            var center = CGPoint(x: 0, y: -ringRadius + itemRadius).applying(
                CGAffineTransform(rotationAngle: step * Double(index))
            )
            center.x += bounds.midX
            center.y += bounds.midY
            let proposal = ProposedViewSize(width: 2 * itemRadius, height: 2 * itemRadius)
            subview.place(at: center, anchor: .center, proposal: proposal)
        }
    }
}

#Preview {
    RadialLayout {
        ForEach(Array(stride(from: 0.0, to: 1.0, by: 1.0 / 12.0)), id: \.self) {
            Color(hue: $0, saturation: 0.5, brightness: 1.0)
                .clipShape(.circle)
        }
    }
    .scaledToFit()
    .border(.red)
    .padding()
}
