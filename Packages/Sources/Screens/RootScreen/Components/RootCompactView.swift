import MyToyboxCore
import SwiftUI

// MARK: - RootCompactView

/// A compact one-column layout backed by `NavigationStack`.
///
/// The navigation path mirrors `selection`, so a screen opened in the split
/// layout stays presented after switching to this layout and vice versa.
struct RootCompactView<Screen: MyToyboxScreen>: View {
    /// The filtered screens rendered in the list.
    let screens: [Screen]
    /// The screen pushed onto the stack, or `nil` while the list is shown.
    @Binding var selection: Screen?

    init(screens: [Screen], selection: Binding<Screen?>) {
        self.screens = screens
        self._selection = selection
    }

    var body: some View {
        NavigationStack(path: path) {
            RootSidebarView(screens: screens)
                // Compact layouts keep the richer row style with leading previews.
                .environment(\.rootCellStyle, .previewLeading)
        }
    }

    /// A single-element path derived from `selection`.
    private var path: Binding<[Screen]> {
        Binding {
            selection.map { [$0] } ?? []
        } set: { path in
            selection = path.last
        }
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview {
    @Previewable @State var selection: MockScreen?
    RootCompactView(screens: MockScreen.allCases, selection: $selection)
        .preferredColorScheme(.dark)
}
#endif
