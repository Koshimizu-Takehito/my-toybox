import MyToyboxCore
import SwiftUI

// MARK: - UnevenRoundedRectangle2Screen

/// A screen that demonstrates the visual differences between several shape types
/// when used to clip a view in SwiftUI, including `Rectangle`, `RoundedRectangle`,
/// and `UnevenRoundedRectangle` (iOS 17+).
@Metadata(title: .screenUnevenRoundedRectanglePresetsTitle, description: .screenUnevenRoundedRectanglePresetsDescription, tags: [])
public struct UnevenRoundedRectangle2Screen: View {
    public init() {}

    /// The large corner radius, proportional to the cell size so narrow cells keep their shape.
    @State private var largeRadius: CGFloat = 80

    public var body: some View {
        HStack(spacing: 20) {
            // Left column using legacy `Shape`-based API
            VStack(spacing: 20, content: leftColumn)
                .environment(MyStyle(background: .orange))

            // Right column using `.rect(...)` shapeStyle syntax
            VStack(spacing: 20, content: rightColumn)
                .environment(MyStyle(background: .mint))
        }
        .padding()
        .onGeometryChange(for: CGFloat.self) { proxy in
            let cell = min((proxy.size.width - 20) / 2, (proxy.size.height - 40) / 3)
            return max(min(80, 0.4 * cell), 0)
        } action: { radius in
            largeRadius = radius
        }
    }

    /// Displays `HelloWorld` with traditional clip shapes
    @ViewBuilder
    private func leftColumn() -> some View {
        HelloWorld()
            .clipShape(Rectangle())
        HelloWorld()
            .clipShape(RoundedRectangle(cornerRadius: 20))
        HelloWorld()
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: largeRadius))
    }

    /// Displays `HelloWorld` with shorthand `.rect(...)` API
    @ViewBuilder
    private func rightColumn() -> some View {
        HelloWorld()
            .clipShape(.rect)
        HelloWorld()
            .clipShape(.rect(cornerRadius: 20))
        HelloWorld()
            .clipShape(.rect(topLeadingRadius: largeRadius))
    }
}

// MARK: - HelloWorld

/// A reusable view displaying "Hello, world!" using the injected `MyStyle`
/// for foreground and background styling.
private struct HelloWorld: View {
    @Environment(MyStyle.self) private var style

    var body: some View {
        Text(verbatim: "Hello, world!")
            .font(.largeTitle.bold())
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 8)
            .foregroundStyle(style.foreground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(style.background.gradient)
    }
}

// MARK: - MyStyle

/// A simple environment container for foreground and background colors
@Observable
private class MyStyle {
    let foreground: Color
    let background: Color

    init(foreground: Color = .white, background: Color = .black) {
        self.foreground = foreground
        self.background = background
    }
}

// MARK: - Preview

#Preview {
    UnevenRoundedRectangle2Screen()
}
