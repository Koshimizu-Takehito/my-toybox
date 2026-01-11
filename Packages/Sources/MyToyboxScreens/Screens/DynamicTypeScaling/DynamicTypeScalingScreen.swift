import SwiftUI

// MARK: - DynamicTypeScalingScreen

/// A screen that demonstrates how `@ScaledMetric` adapts to various `DynamicTypeSize` settings.
/// Users can drag the slider to simulate different accessibility text sizes and observe how
/// the scaled values change across different text styles.
struct DynamicTypeScalingScreen: View {
    @State private var dynamicTypeSizeIndex: Double = 3.0

    var body: some View {
        VStack {
            // Scaled metric values rendered under the selected dynamic type size
            ScaledMetrics()
                .environment(\.dynamicTypeSize, .allCases[Int(dynamicTypeSizeIndex)])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .contentTransition(.numericText())

            // Displays the name of the current `DynamicTypeSize`
            Text(String(describing: DynamicTypeSize.allCases[Int(dynamicTypeSizeIndex)]))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.identity)

            // Slider to adjust the dynamic type size index
            Slider(value: $dynamicTypeSizeIndex.animation(), in: 0 ... 11)
        }
        .font(.system(size: 30).monospacedDigit().bold())
        .padding()
    }
}

// MARK: - ScaledMetrics

/// Displays `@ScaledMetric` values for all major text styles.
/// Each value is automatically updated based on the current `DynamicTypeSize`.
struct ScaledMetrics: View {
    @ScaledMetric(relativeTo: .largeTitle) private var scaledLargeTitle = 100.0
    @ScaledMetric(relativeTo: .title) private var scaledTitle = 100.0
    @ScaledMetric(relativeTo: .title2) private var scaledTitle2 = 100.0
    @ScaledMetric(relativeTo: .title3) private var scaledTitle3 = 100.0
    @ScaledMetric(relativeTo: .headline) private var scaledHeadline = 100.0
    @ScaledMetric(relativeTo: .subheadline) private var scaledSubheadline = 100.0
    @ScaledMetric(relativeTo: .body) private var scaledBody = 100.0
    @ScaledMetric(relativeTo: .callout) private var scaledCallout = 100.0
    @ScaledMetric(relativeTo: .footnote) private var scaledFootnote = 100.0
    @ScaledMetric(relativeTo: .caption) private var scaledCaption = 100.0
    @ScaledMetric(relativeTo: .caption2) private var scaledCaption2 = 100.0

    var body: some View {
        VStack(alignment: .trailing) {
            SampleRow(scaledLargeTitle, name: "largeTitle")
            SampleRow(scaledTitle, name: "title")
            SampleRow(scaledTitle2, name: "title2")
            SampleRow(scaledTitle3, name: "title3")
            SampleRow(scaledHeadline, name: "headline")
            SampleRow(scaledSubheadline, name: "subheadline")
            SampleRow(scaledBody, name: "body")
            SampleRow(scaledCallout, name: "callout")
            SampleRow(scaledFootnote, name: "footnote")
            SampleRow(scaledCaption, name: "caption")
            SampleRow(scaledCaption2, name: "caption2")
        }
    }
}

// MARK: - SampleRow

/// A reusable view that shows a text style name and its corresponding scaled metric value.
private struct SampleRow: View {
    let name: String
    let value: Double

    init(_ value: Double, name: String) {
        self.name = name
        self.value = value
    }

    var body: some View {
        HStack {
            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: "%.1f", value))
                .fixedSize()
        }
    }
}

// MARK: - Preview

#Preview {
    DynamicTypeScalingScreen()
}
