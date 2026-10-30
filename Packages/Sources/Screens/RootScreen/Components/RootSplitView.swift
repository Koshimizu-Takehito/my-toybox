import DetailScreen
import MyToyboxCore
import SwiftUI

// MARK: - RootSplitView

/// A split layout that presents a sidebar and a detail pane.
struct RootSplitView<Screen: MyToyboxScreen>: View {
    /// The filtered screens to render in the sidebar.
    private let screens: [Screen]
    /// The screen the user picked, shared with the compact layout.
    @Binding private var selection: Screen?

    init(screens: [Screen], selection: Binding<Screen?>) {
        self.screens = screens
        self._selection = selection
    }

    var body: some View {
        NavigationSplitView {
            RootSidebarView(screens: screens, selection: displayedSelection)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 380)
        } detail: {
            NavigationStack {
                DetailScreen(screen: displayedSelection.wrappedValue)
                    .toolbarTitleDisplayMode(.inline)
            }
        }
    }

    /// The selection shown by this layout.
    ///
    /// Falls back to the first visible screen without writing it back, so the
    /// compact layout still opens on the list when the user has not picked anything.
    private var displayedSelection: Binding<Screen?> {
        Binding {
            if let selection, screens.contains(selection) {
                selection
            } else {
                screens.first
            }
        } set: { screen in
            selection = screen
        }
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview {
    @Previewable @State var selection: MockScreen? = .mockA
    RootSplitView(screens: MockScreen.allCases, selection: $selection)
        .preferredColorScheme(.dark)
}
#endif
