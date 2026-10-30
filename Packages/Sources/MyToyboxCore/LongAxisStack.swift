import SwiftUI

// MARK: - LongAxisStack

/// A stack that lines its children up along the longer side of the space it is given:
/// horizontally when wider than tall, vertically otherwise.
///
/// Useful for before/after comparisons, which stay large in both portrait and
/// landscape instead of shrinking into a single column.
public struct LongAxisStack<Content: View>: View {
    private let spacing: CGFloat?
    private let content: Content

    public init(spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in
            let layout = proxy.size.width > proxy.size.height
                ? AnyLayout(HStackLayout(spacing: spacing))
                : AnyLayout(VStackLayout(spacing: spacing))
            layout {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
