import MyToyboxCore
import SwiftUI

// MARK: - DetailScreen

/// The detail pane shown when a screen is selected from the root list.
///
/// If `screen` is `nil` (e.g. nothing selected yet in split layout),
/// a placeholder prompt is displayed instead.
public struct DetailScreen<Screen: MyToyboxScreen>: View {
    /// The screen to present, or `nil` to show the empty-selection placeholder.
    private let screen: Screen?

    public nonisolated init(screen: Screen?) {
        self.screen = screen
    }

    @ViewBuilder
    public var body: some View {
        Group {
            if let screen {
                screen
                    .navigationTitle(screen.title)
            } else {
                Text(.appSelectScreen)
                    .navigationTitle(.appTitle)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview("With Screen") {
    NavigationStack {
        DetailScreen(screen: MockScreen.mockA)
    }
}

#Preview("Empty") {
    NavigationStack {
        DetailScreen<MockScreen>(screen: nil)
    }
}
#endif
