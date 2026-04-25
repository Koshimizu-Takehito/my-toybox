import MyToyboxCore
import SwiftUI

// MARK: - RootSplitView

/// A split layout that presents a sidebar and a detail pane.
struct RootSplitView: View {
    /// The filtered screens to render in the sidebar.
    let screens: [Screen]
    /// The selected screen shown in the detail pane.
    @Binding var selection: Screen?

    var body: some View {
        NavigationSplitView {
            RootSidebarView(screens: screens, selection: $selection)
        } detail: {
            NavigationStack {
                RootDetailView(selection: selection)
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
