import MyToyboxCore
import SwiftUI

// MARK: - RootDetailView

/// A detail container that renders the selected screen or a placeholder.
struct RootDetailView: View {
    /// The currently selected screen.
    let selection: Screen?

    var body: some View {
        Group {
            if let selection {
                selection
            } else {
                Text(.appSelectScreen)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(selection?.title ?? .appTitle)
    }
}
