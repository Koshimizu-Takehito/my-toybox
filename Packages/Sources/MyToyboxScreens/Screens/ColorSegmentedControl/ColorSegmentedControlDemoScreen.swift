import SwiftUI

// MARK: - ColorSegmentedControlDemoScreen

/// A demo screen showcasing a custom color-based segmented control component.
/// Displays a list of segments and shows the selected segment's value in a large, bold title.
struct ColorSegmentedControlDemoScreen: View {
    /// The static list of selectable segments.
    private static let demoItems: [ColorItem] = [
        ColorItem(value: "Apple", color: .red),
        ColorItem(value: "Orange", color: .orange.mix(with: .pink, by: 0.4)),
        ColorItem(value: "Muscat", color: .green),
    ]

    /// The currently selected segment binding.
    @State private var selectedSegment = Self.demoItems[0]

    var body: some View {
        VStack {
            ColorSegmentedControl(selection: $selectedSegment, items: Self.demoItems)

            Text(String(describing: selectedSegment.value))
                .lineLimit(1)
                .font(.largeTitle.bold())
                .foregroundStyle(selectedSegment.color)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: 360, maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(selectedSegment.color.opacity(0.3))
    }
}

// MARK: - ColorItem

/// A selectable item with an associated display color.
struct ColorItem<Value: Hashable>: Identifiable, Hashable {
    /// Unique identifier for diffing and animations.
    var id = UUID()
    /// The underlying value of this segment.
    var value: Value
    /// The highlight color for this segment when selected.
    var color: Color
}

// MARK: - ColorSegmentedControl

/// A generic, color-highlighted segmented control that animates
/// transitions between selections using SwiftUI’s matched geometry effect.
///
/// Displays a capsule-shaped selection indicator behind the active segment.
/// `ColorItem`’s `id` and `color` are used to drive the animation and styling.
///
/// - Parameters:
///   - selection: Two-way binding to the currently selected segment.
///   - items: The list of segments to render in this control.
struct ColorSegmentedControl<Value: Hashable>: View {
    /// Namespace for matched-geometry animations between segments.
    @Namespace private var namespace

    /// Two-way binding to the currently selected segment.
    @Binding var selection: ColorItem<Value>

    /// The list of segments to render in this control.
    var items: [ColorItem<Value>]

    var body: some View {
        ZStack {
            SelectedSegment()
                .matchedGeometryEffect(id: selection.id, in: namespace, isSource: false)

            HStack {
                ForEach(items) { item in
                    Segment(value: item.value, isSelected: selection == item) {
                        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                            selection = item
                        }
                    }
                    .matchedGeometryEffect(id: item.id, in: namespace, isSource: true)
                }
                .padding(2)
            }
        }
        .background(.tint.opacity(0.2))
        .background(.white)
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(Capsule(style: .continuous))
        .tint(selection.color)
    }
}

// MARK: - SelectedSegment

/// The capsule-shaped background for the selected segment.
private struct SelectedSegment: View {
    var body: some View {
        Capsule(style: .continuous)
            .foregroundStyle(.tint)
            .padding(2)
            .shadow(radius: 2)
    }
}

// MARK: - Segment

/// A single segment button with its text label and styling.
///
/// - Parameters:
///   - value: The value displayed in this segment.
///   - isSelected: A Boolean indicating if this segment is the current selection.
///   - action: The closure to invoke when this segment is tapped.
private struct Segment<Value: Hashable>: View {
    /// The model value for this segment.
    var value: Value
    /// Whether this segment is currently selected.
    var isSelected: Bool
    /// Action invoked when the button is tapped.
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(String(describing: value))
                .lineLimit(1)
                .minimumScaleFactor(1)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.tint))
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    ColorSegmentedControlDemoScreen()
}
