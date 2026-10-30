import SwiftUI

// MARK: - CanvasControlsLayout

/// A layout that arranges exactly two subviews, a canvas and its controls,
/// either stacked vertically or side by side.
///
/// The arrangement is chosen from the space the layout is offered, not from the
/// size class, because a detail column can be narrow on a regular-width device
/// (an unfolded iPhone Duo or an iPad) and wide on a compact one (a folded iPhone
/// Duo in landscape). It picks whichever arrangement leaves the larger visible
/// canvas, preferring the stacked one on ties, so it follows a fold or rotation
/// live without keeping any state.
///
/// Spacing conventions shared by screens that use this layout:
/// - The outer margin is the system `.padding()` (applied by ``CanvasControlsStack``).
/// - Canvas and controls are separated by the system spacing unless `spacing` is set.
/// - Control panels use `.padding()` inside and a corner radius of 12.
public struct CanvasControlsLayout: Layout {
    /// How the canvas and the controls are placed relative to each other.
    public enum Arrangement: Equatable, Sendable {
        /// Controls below the canvas.
        case stacked
        /// Controls in a trailing column next to the canvas.
        case sideBySide
    }

    /// The width-to-height ratio of the canvas content, or `nil` when the canvas fills any shape.
    public var canvasAspectRatio: CGFloat?
    /// The distance between the canvas and the controls, or `nil` for the system spacing.
    public var spacing: CGFloat?
    /// The allowed width of the controls. Its upper bound also caps stacked controls.
    public var controlsWidth: ClosedRange<CGFloat>

    /// The largest share of the height that stacked controls may take before they scroll.
    static let maxStackedControlsShare: CGFloat = 0.5
    /// The share of the width given to the controls column when side by side.
    static let sideBySideControlsShare: CGFloat = 0.4

    public init(
        canvasAspectRatio: CGFloat? = 1,
        spacing: CGFloat? = nil,
        controlsWidth: ClosedRange<CGFloat> = 260 ... 400
    ) {
        self.canvasAspectRatio = canvasAspectRatio
        self.spacing = spacing
        self.controlsWidth = controlsWidth
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout Void) -> CGSize {
        guard subviews.count == 2 else {
            return proposal.replacingUnspecifiedDimensions()
        }
        let width = proposal.width ?? 320
        if let height = proposal.height {
            return CGSize(width: width, height: height)
        }
        // Without a height to fill, report the natural stacked height.
        let spacing = resolvedSpacing(subviews)
        let controlsWidth = min(width, controlsWidth.upperBound)
        let controlsHeight = subviews[1].sizeThatFits(ProposedViewSize(width: controlsWidth, height: nil)).height
        let canvasHeight = canvasAspectRatio.map { width / $0 } ?? width
        return CGSize(width: width, height: canvasHeight + spacing + controlsHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout Void) {
        guard subviews.count == 2 else {
            for subview in subviews {
                subview.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
            }
            return
        }
        let canvas = subviews[0]
        let controls = subviews[1]
        let spacing = resolvedSpacing(subviews)
        let stackedControlsWidth = min(bounds.width, controlsWidth.upperBound)
        let stackedControlsHeight = min(
            controls.sizeThatFits(ProposedViewSize(width: stackedControlsWidth, height: nil)).height,
            bounds.height * Self.maxStackedControlsShare
        )

        switch Self.arrangement(
            in: bounds.size,
            stackedControlsHeight: stackedControlsHeight,
            spacing: spacing,
            canvasAspectRatio: canvasAspectRatio,
            controlsWidth: controlsWidth
        ) {
        case .stacked:
            let area = CGSize(width: bounds.width, height: max(bounds.height - stackedControlsHeight - spacing, 0))
            let canvasSize = Self.fittedSize(in: area, aspectRatio: canvasAspectRatio)
            // Center the canvas and the controls as one group.
            let top = bounds.minY + (bounds.height - canvasSize.height - spacing - stackedControlsHeight) / 2
            canvas.place(
                at: CGPoint(x: bounds.midX, y: top),
                anchor: .top,
                proposal: ProposedViewSize(canvasSize)
            )
            controls.place(
                at: CGPoint(x: bounds.midX, y: top + canvasSize.height + spacing),
                anchor: .top,
                proposal: ProposedViewSize(width: stackedControlsWidth, height: stackedControlsHeight)
            )

        case .sideBySide:
            let columnWidth = Self.sideBySideControlsWidth(for: bounds.width, controlsWidth: controlsWidth)
            let area = CGSize(width: max(bounds.width - columnWidth - spacing, 0), height: bounds.height)
            let canvasSize = Self.fittedSize(in: area, aspectRatio: canvasAspectRatio)
            let leading = bounds.minX + (bounds.width - canvasSize.width - spacing - columnWidth) / 2
            canvas.place(
                at: CGPoint(x: leading, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(canvasSize)
            )
            let controlsHeight = min(
                controls.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil)).height,
                bounds.height
            )
            controls.place(
                at: CGPoint(x: leading + canvasSize.width + spacing, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(width: columnWidth, height: controlsHeight)
            )
        }
    }
}

// MARK: - Arrangement

extension CanvasControlsLayout {
    /// Returns the arrangement that leaves the larger visible canvas in `size`.
    ///
    /// - Parameters:
    ///   - size: The space offered to the layout.
    ///   - stackedControlsHeight: The controls' height when stacked, already capped.
    ///   - spacing: The distance between the canvas and the controls.
    ///   - canvasAspectRatio: The canvas width-to-height ratio, or `nil` to compare plain areas.
    ///   - controlsWidth: The allowed width of the controls.
    static func arrangement(
        in size: CGSize,
        stackedControlsHeight: CGFloat,
        spacing: CGFloat,
        canvasAspectRatio: CGFloat?,
        controlsWidth: ClosedRange<CGFloat>
    ) -> Arrangement {
        let stackedArea = CGSize(width: size.width, height: max(size.height - stackedControlsHeight - spacing, 0))
        let columnWidth = sideBySideControlsWidth(for: size.width, controlsWidth: controlsWidth)
        let sideBySideArea = CGSize(width: max(size.width - columnWidth - spacing, 0), height: size.height)
        let stacked = visibleArea(of: fittedSize(in: stackedArea, aspectRatio: canvasAspectRatio))
        let sideBySide = visibleArea(of: fittedSize(in: sideBySideArea, aspectRatio: canvasAspectRatio))
        return sideBySide > stacked ? .sideBySide : .stacked
    }

    /// The width of the controls column when side by side.
    static func sideBySideControlsWidth(for width: CGFloat, controlsWidth: ClosedRange<CGFloat>) -> CGFloat {
        min(max(width * sideBySideControlsShare, controlsWidth.lowerBound), controlsWidth.upperBound)
    }

    /// The largest size with `aspectRatio` that fits in `area`, or `area` itself when the ratio is `nil`.
    static func fittedSize(in area: CGSize, aspectRatio: CGFloat?) -> CGSize {
        guard let aspectRatio, aspectRatio > 0, area.width > 0, area.height > 0 else {
            return area
        }
        if area.width / area.height > aspectRatio {
            return CGSize(width: area.height * aspectRatio, height: area.height)
        } else {
            return CGSize(width: area.width, height: area.width / aspectRatio)
        }
    }

    private static func visibleArea(of size: CGSize) -> CGFloat {
        size.width * size.height
    }

    private func resolvedSpacing(_ subviews: Subviews) -> CGFloat {
        spacing ?? subviews[0].spacing.distance(to: subviews[1].spacing, along: .vertical)
    }
}

// MARK: - CanvasControlsStack

/// A canvas with a control panel that switches between a stacked and a
/// side-by-side arrangement to fit the available space.
///
/// It applies the outer margin and makes the controls scrollable when they do
/// not fit, so screens should not add their own outer padding around it.
public struct CanvasControlsStack<Canvas: View, Controls: View>: View {
    private let layout: CanvasControlsLayout
    private let canvas: Canvas
    private let controls: Controls

    /// Creates a canvas-and-controls stack.
    ///
    /// - Parameters:
    ///   - canvasAspectRatio: The width-to-height ratio of the canvas, or `nil` when it fills any shape.
    ///   - spacing: The distance between the canvas and the controls, or `nil` for the system spacing.
    ///   - canvas: The visual content.
    ///   - controls: The controls that drive the canvas.
    public init(
        canvasAspectRatio: CGFloat? = 1,
        spacing: CGFloat? = nil,
        @ViewBuilder canvas: () -> Canvas,
        @ViewBuilder controls: () -> Controls
    ) {
        self.layout = CanvasControlsLayout(canvasAspectRatio: canvasAspectRatio, spacing: spacing)
        self.canvas = canvas()
        self.controls = controls()
    }

    public var body: some View {
        layout {
            canvas
            ScrollView {
                controls
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding()
    }
}
