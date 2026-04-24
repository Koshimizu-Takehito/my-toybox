import MyToyboxCore
import SwiftUI

// MARK: - TagPicker

/// A view that displays a button which, when tapped, presents a popover
/// containing tag selection controls driven by `TagSelectionModel`.
struct TagPicker: View {
    /// Tracks whether the tag picker popover is currently presented.
    @State private var isPopoverPresented = false

    /// The model providing selection state, injected from the environment.
    @Environment(TagSelectionModel.self) private var model

    var body: some View {
        PickerButton(model: model, isPopoverPresented: $isPopoverPresented)
            .popover(isPresented: $isPopoverPresented) {
                PickerPopover(model: model)
            }
    }
}

// MARK: - PickerButton

/// A button that toggles display of the tag picker popover.
private struct PickerButton: View {
    /// The underlying model driving the picker state.
    var model: TagSelectionModel

    /// Binding to control popover presentation.
    @Binding var isPopoverPresented: Bool

    var body: some View {
        Button(action: togglePopover) {
            Image(systemName: iconName)
                .imageScale(.large)
                .animation(.default, value: model.selections)
        }
    }

    /// Computes the correct SF Symbol based on whether any tags are selected.
    private var iconName: String {
        model.selected.isEmpty
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }

    /// Toggles the popover's visibility state.
    private func togglePopover() {
        isPopoverPresented.toggle()
    }
}

// MARK: - PickerPopover

/// A popover view displaying a flow layout of tag toggles
/// and controls to select or deselect all tags.
private struct PickerPopover: View {
    /// The model bound to the picker, allowing two-way updates.
    @Bindable var model: TagSelectionModel

    var body: some View {
        let selectedTags = model.selected

        VStack {
            // FlowLayout for toggling individual tags
            PickerFlowLayout(alignment: .leading, spacing: 8) {
                ForEach($model.selections, id: \.tag) { $selection in
                    PickerToggle(selection: $selection)
                }
            }

            Divider()
                .padding(.vertical)

            // Action buttons
            HStack(spacing: 0) {
                Button(action: deselectAll) {
                    Text(.tagPickerClearAll)
                }
                .disabled(selectedTags.isEmpty)
                .frame(maxWidth: .infinity)

                Button(action: selectAll) {
                    Text(.tagPickerSelectAll)
                }
                .disabled(selectedTags == Tag.allCases)
                .frame(maxWidth: .infinity)
            }
        }
        .animation(.default, value: selectedTags)
        .frame(idealWidth: 300)
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .presentationCompactAdaptation(.popover)
    }

    /// Selects every tag with animation.
    private func selectAll() {
        withAnimation {
            model.selectAll()
        }
    }

    /// Deselects every tag with animation.
    private func deselectAll() {
        withAnimation {
            model.deselectAll()
        }
    }
}

// MARK: - PickerToggle

/// A toggle button that represents a single tag selection.
private struct PickerToggle: View {
    /// Binding to an individual tag's selection state.
    @Binding var selection: TagSelectionModel.Selection
    @State private var isOn: Bool

    init(selection: Binding<TagSelectionModel.Selection>) {
        _selection = selection
        _isOn = State(initialValue: selection.wrappedValue.isSelected)
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(selection.tag.localizedTitle)
        }
        .toggleStyle(.button)
        .tint(selection.color)
        .onChange(of: selection.isSelected, initial: true) { _, isSelected in
            withAnimation {
                isOn = isSelected
            }
        }
        .onChange(of: isOn, initial: true) { _, isOn in
            withAnimation {
                selection.isSelected = isOn
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TagPicker()
        .environment(TagSelectionModel())
}
