import MyToyboxAppScreens
import RootScreen
import SwiftUI
import TagPicker

// MARK: - App

@main
struct App: SwiftUI::App {
    var body: some Scene {
        WindowGroup {
            RootScreen<AppScreen>()
                .rootToolbar(content: TagPicker.init)
        }
    }
}

// MARK: - RootScreen

#Preview {
    RootScreen<AppScreen>()
}
