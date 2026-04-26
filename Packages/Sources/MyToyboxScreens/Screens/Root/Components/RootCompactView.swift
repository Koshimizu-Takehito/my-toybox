import MyToyboxCore
import SwiftUI

// MARK: - RootCompactView

/// A compact one-column layout backed by `NavigationStack`.
struct RootCompactView: View {
    /// The filtered screens rendered in the list.
    let screens: [Screen]

    var body: some View {
        NavigationStack {
            RootSidebarView(screens: screens)
                // Compact layouts keep the richer row style with leading previews.
                .environment(\.rootCellStyle, .previewLeading)
        }
    }
}
