import SwiftUI

// MARK: - Route sheet presentation

public extension View {
    /// Presents a routed destination as a sheet when a deep link or
    /// Universal Link is received.
    func deepLinkSheet<Screen: MyToyboxScreen>(
        for _: Screen.Type = Screen.self,
        @ViewBuilder content: @escaping (Screen?) -> some View
    ) -> some View {
        modifier(DeepLinkSheet(content: content))
    }
}

// MARK: - DeepLinkSheet

private struct DeepLinkSheet<Screen: MyToyboxScreen, ScreenContent: View>: ViewModifier {
    /// The resolved route. Non-nil while the sheet is presented.
    @State private var screen: Screen?
    private var screenContent: (Screen?) -> ScreenContent

    init(content screenContent: @escaping (Screen?) -> ScreenContent) {
        self.screenContent = screenContent
    }

    func body(content: Content) -> some View {
        content
            .onRecieve(screen: $screen)
            .sheet(item: $screen) { screen in
                NavigationStack {
                    screenContent(screen)
                }
            }
    }
}
