import CoreGraphics
@testable import MyToyboxCore
import Testing

@Suite struct CanvasControlsLayoutTests {
    /// Sizes that appear on iPhone Duo and in narrow split detail columns.
    @Test(arguments: [
        // Narrow split detail column.
        (CGSize(width: 349, height: 400), CanvasControlsLayout.Arrangement.stacked),
        // Folded, portrait.
        (CGSize(width: 466, height: 580), .stacked),
        // Folded, landscape.
        (CGSize(width: 678, height: 400), .sideBySide),
        // Unfolded, portrait.
        (CGSize(width: 669, height: 850), .stacked),
        // Unfolded, landscape with the sidebar shown.
        (CGSize(width: 630, height: 600), .stacked),
        // Unfolded, landscape with the sidebar hidden.
        (CGSize(width: 951, height: 600), .sideBySide),
    ])
    func arrangement(size: CGSize, expected: CanvasControlsLayout.Arrangement) {
        let arrangement = CanvasControlsLayout.arrangement(
            in: size,
            stackedControlsHeight: 200,
            spacing: 8,
            canvasAspectRatio: 1,
            controlsWidth: 260 ... 400
        )
        #expect(arrangement == expected)
    }

    @Test func fillingCanvasPrefersStackedOnTallSpace() {
        let arrangement = CanvasControlsLayout.arrangement(
            in: CGSize(width: 466, height: 580),
            stackedControlsHeight: 200,
            spacing: 8,
            canvasAspectRatio: nil,
            controlsWidth: 260 ... 400
        )
        #expect(arrangement == .stacked)
    }

    @Test func fittedSizeKeepsAspectRatio() {
        let size = CanvasControlsLayout.fittedSize(in: CGSize(width: 300, height: 100), aspectRatio: 1.5)
        #expect(size == CGSize(width: 150, height: 100))
    }

    @Test func sideBySideControlsWidthIsClamped() {
        #expect(CanvasControlsLayout.sideBySideControlsWidth(for: 400, controlsWidth: 260 ... 400) == 260)
        #expect(CanvasControlsLayout.sideBySideControlsWidth(for: 1200, controlsWidth: 260 ... 400) == 400)
    }
}
