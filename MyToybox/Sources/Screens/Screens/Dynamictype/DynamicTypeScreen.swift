import SwiftUI

// MARK: - DynamicTypeScreen

/// A screen demonstrating the difference between system font scaling
/// and manually scaled font sizes using `@ScaledMetric`.
struct DynamicTypeScreen: View {
    @State private var dynamicTypeIndex: Double = 4.0
    // Sample text reused for layout clarity
    private let sampleText = Text("Hello")

    var body: some View {
        VStack {
            // Grid showing system font vs. custom scaled font for each text style
            Grid(alignment: .leading) {
                GridRow {
                    sampleText.font(.largeTitle)
                    sampleText.myStyle(.style1)
                }
                GridRow {
                    sampleText.font(.title)
                    sampleText.myStyle(.style2)
                }
                GridRow {
                    sampleText.font(.body)
                    sampleText.myStyle(.style3)
                }
            }
            .frame(maxHeight: .infinity)
            .environment(\.dynamicTypeSize, .allCases[Int(dynamicTypeIndex)])

            // Shows the name of the current DynamicTypeSize
            Text(String(describing: DynamicTypeSize.allCases[Int(dynamicTypeIndex)]))
                .font(.title)
                .contentTransition(.interpolate)

            // Slider to change the DynamicTypeSize
            Slider(value: $dynamicTypeIndex, in: 0...11)
        }
        .animation(.default, value: dynamicTypeIndex)
        .padding()
    }
}

// MARK: - MyStyle (custom style enum)

/// Enumeration representing custom font styles associated with specific system text styles.
private enum MyStyle: CaseIterable {
    case style1
    case style2
    case style3
}

// MARK: - MyFontSize

/// Provides scaled font sizes using `@ScaledMetric` for each custom style.
private struct MyFontSize: DynamicProperty {
    @ScaledMetric(relativeTo: .largeTitle) private var scaledLargeTitleSize = 34.0
    @ScaledMetric(relativeTo: .title) private var scaledTitleSize = 28.0
    @ScaledMetric(relativeTo: .body) private var scaledBodySize = 17.0

    /// Returns the font size corresponding to the given style.
    func value(for style: MyStyle) -> Double {
        switch style {
        case .style1:
            return scaledLargeTitleSize
        case .style2:
            return scaledTitleSize
        case .style3:
            return scaledBodySize
        }
    }
}

// MARK: - MyStyleModifier

/// A view modifier that applies a custom scaled font to content.
private struct MyStyleModifier: ViewModifier {
    let style: MyStyle
    private let fontSize = MyFontSize()

    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize.value(for: style), design: .serif))
    }
}

// MARK: - View Extension

/// Convenience method for applying a custom style modifier.
extension View {
    fileprivate func myStyle(_ style: MyStyle) -> some View {
        modifier(MyStyleModifier(style: style))
    }
}

// MARK: - Preview

#Preview {
    DynamicTypeScreen()
}
