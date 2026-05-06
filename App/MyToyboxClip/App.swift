import MyToyboxClipScreens
import MyToyboxUI
import SwiftUI

// MARK: - App

@main
struct App: SwiftUI::App {
    var body: some Scene {
        WindowGroup {
            RootScreen<Screen>()
                .rootListStyle(.appClip)
        }
    }
}
