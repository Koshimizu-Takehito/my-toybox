import SwiftUI

// MARK: - UnevenRoundedRectangle2Screen

/// A screen that demonstrates the visual differences between several shape types
/// when used to clip a view in SwiftUI, including `Rectangle`, `RoundedRectangle`,
/// and `UnevenRoundedRectangle` (iOS 17+).
@Metadata(title: .screenUnevenRoundedRectanglePresetsTitle, description: .screenUnevenRoundedRectanglePresetsDescription, tags: [])
struct UnevenRoundedRectangle2Screen: View {
    var body: some View {
        HStack(spacing: 20) {
            // Left column using legacy `Shape`-based API
            VStack(spacing: 20, content: leftColumn)
                .environment(MyStyle(background: .orange))

            // Right column using `.rect(...)` shapeStyle syntax
            VStack(spacing: 20, content: rightColumn)
                .environment(MyStyle(background: .mint))
        }
        .padding(20)
    }

    /// Displays `HelloWorld` with traditional clip shapes
    @ViewBuilder
    private func leftColumn() -> some View {
        HelloWorld()
            .clipShape(Rectangle())
        HelloWorld()
            .clipShape(RoundedRectangle(cornerRadius: 20))
        HelloWorld()
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 80))
    }

    /// Displays `HelloWorld` with shorthand `.rect(...)` API
    @ViewBuilder
    private func rightColumn() -> some View {
        HelloWorld()
            .clipShape(.rect)
        HelloWorld()
            .clipShape(.rect(cornerRadius: 20))
        HelloWorld()
            .clipShape(.rect(topLeadingRadius: 80))
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
