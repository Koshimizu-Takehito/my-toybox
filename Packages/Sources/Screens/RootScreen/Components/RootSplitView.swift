import DetailScreen
import MyToyboxCore
import SwiftUI

// MARK: - RootSplitView

/// A split layout that presents a sidebar and a detail pane.
struct RootSplitView<Screen: MyToyboxScreen>: View {
    /// The filtered screens to render in the sidebar.
    private let screens: [Screen]
    /// The selected screen shown in the detail pane.
    @Binding private var selection: Screen?

    init(screens: [Screen], selection: Binding<Screen?>) {
        self.screens = screens
        self._selection = selection
    }

    var body: some View {
        NavigationSplitView {
            RootSidebarView(screens: screens, selection: $selection)
        } detail: {
            NavigationStack {
                DetailScreen(screen: selection)
                    .toolbarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: screens, initial: true) { _, screens in
            if let selection, screens.contains(selection) {
                return
            }
            selection = screens.first
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
