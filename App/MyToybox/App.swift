import MyToyboxScreens
import MyToyboxUI
import SwiftUI
import TagPicker

// MARK: - App

@main
struct App: SwiftUI::App {
    var body: some Scene {
        WindowGroup {
            RootScreen<Screen>()
                .rootListStyle(.default)
                .rootToolbar(content: TagPicker.init)
        }
    }
}

// MARK: - RootScreen

#Preview {
    RootScreen<Screen>()
        .rootToolbar(content: TagPicker.init)
}
