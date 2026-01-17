import SwiftUI

// MARK: - StrokeModifierDemoScreen

/// A sample screen demonstrating three stacked stroke effects produced by
/// `StrokeModifier`.
/// Each call to `.stroke(_:width:)` adds an additional blurred outline,
/// resulting in a multi-layered border.
@Metadata(title: "Stroke modifier", description: "ビューに枠線を引く", tags: [])
struct StrokeModifierDemoScreen: View {
    var body: some View {
        VStack {
            Image(systemName: "swift")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 256)
                .padding(16)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("Hello, World!!")
                .font(.system(size: 56, weight: .bold, design: .default))
                .foregroundStyle(.foreground)
                .padding(16)
        }
        .padding(12)
        // Three concentric strokes (white ➜ cyan ➜ blue)
        .stroke(.background, width: 4)
        .stroke(.cyan, width: 4)
        .stroke(.blue, width: 4)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Convenience API

extension View {
    /// Overlays the view with an outward-blurred stroke of the specified color
    /// and width.
    ///
    /// Internally this applies `StrokeModifier`, which builds the outline in a
    /// single off-screen render pass.
    ///
    /// - Parameters:
    ///   - style:  The `ShapeStyle` used to fill the stroke.
    ///             Defaults to solid white.
    ///   - width:  The stroke’s thickness, expressed in points.
    ///             Values ≤ 0 produce no effect.
    /// - Returns: A view with the stroke applied.
    @ViewBuilder
    func stroke(_ style: some ShapeStyle = .white, width: Double = 4) -> some View {
        if let stroke = StrokeModifier(style: style, width: width) {
            modifier(stroke)
        } else {
            modifier(EmptyModifier())
        }
    }
}

// MARK: - StrokeModifier

/// A `ViewModifier` that renders a blurred, outward-growing outline
/// (“stroke”) surrounding the target view.
///
/// The effect is achieved by:
/// 1. Capturing the view’s alpha into a `Canvas` symbol
/// 2. Applying an `alphaThreshold` to make the interior fully opaque
/// 3. Blurring the result by the requested width, which dilates the mask
/// 4. Filling that mask with the supplied `ShapeStyle`
private struct StrokeModifier<Style: ShapeStyle>: ViewModifier {
    /// Style used to fill the generated stroke.
    private var style: Style
    /// Desired thickness of the stroke, in points.
    private var width: Double

    init?(style: Style, width: Double) {
        guard width > 0 else {
            return nil
        }
        self.style = style
        self.width = width
    }

    func body(content: Content) -> some View {
        content.background {
            Rectangle()
                .foregroundStyle(style)
                .mask(alignment: .center) {
                    AlphaThresholdOutlineMask(width: width) {
                        content
                    }
                }
        }
    }
}

// MARK: - AlphaThresholdOutlineMask

private struct AlphaThresholdOutlineMask<Content: View>: View {
    private enum SymbolID: Int {
        case content
    }

    private var width: Double
    private var content: () -> Content

    init(width: Double, @ViewBuilder content: @escaping () -> Content) {
        self.width = width
        self.content = content
    }

    var body: some View {
        Canvas { context, size in
            let symbol = context.resolveSymbol(id: SymbolID.content)!
            // Keep only non-transparent pixels
            context.addFilter(.alphaThreshold(min: 0.01))
            // Dilate the mask by blurring
            context.addFilter(.blur(radius: width))
            context.draw(symbol, at: CGPoint(x: size.width / 2, y: size.height / 2))
        } symbols: {
            content().tag(SymbolID.content)
        }
    }
}

// MARK: - Preview

#Preview {
    StrokeModifierDemoScreen()
}
