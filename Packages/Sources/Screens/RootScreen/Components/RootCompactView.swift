import MyToyboxCore
import SwiftUI

// MARK: - RootCompactView

/// A compact one-column layout backed by `NavigationStack`.
struct RootCompactView<Screen: MyToyboxScreen>: View {
    /// The filtered screens rendered in the list.
    let screens: [Screen]

    init(screens: [Screen]) {
        self.screens = screens
    }

    var body: some View {
        NavigationStack {
            RootSidebarView(screens: screens)
                // Compact layouts keep the richer row style with leading previews.
                .environment(\.rootCellStyle, .previewLeading)
        }
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview {
    RootCompactView(screens: MockScreen.allCases)
        .preferredColorScheme(.dark)
}
#endif
