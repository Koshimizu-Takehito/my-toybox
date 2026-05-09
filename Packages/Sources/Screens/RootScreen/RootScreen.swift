import DetailScreen
import MyToyboxCore
import SwiftUI

// MARK: - RootScreen

/// The top-level entry view that routes between split and compact layouts.
///
/// - On regular width, it uses `RootSplitView`.
/// - On compact width (iPhone), it uses `RootCompactView`.
/// - It injects shared tag selection state into child views.
public struct RootScreen<Screen: MyToyboxScreen>: View {
    /// The view model that loads and filters available screens.
    @State private var viewModel = RootScreenModel<Screen>()
    /// The selected screen used by split layout.
    @State private var selection: Screen?
    /// The current horizontal size class for adaptive routing.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init() {}

    public var body: some View {
        contentView
            .deepLinkSheet(content: DetailScreen<Screen>.init)
            // Force dark mode appearance 😎
            .preferredColorScheme(.dark)
            .environment(viewModel.tags)
    }
}

private extension RootScreen {
    @ViewBuilder
    var contentView: some View {
        let filteredScreens = viewModel.filteredScreens()
        #if os(iOS)
        if horizontalSizeClass == .compact {
            RootCompactView(screens: filteredScreens)
        } else {
            RootSplitView(screens: filteredScreens, selection: $selection)
        }
        #else
        RootSplitView(screens: filteredScreens, selection: $selection)
        #endif
    }
}
