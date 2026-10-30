import ClipScreens
import RootScreen
import SwiftUI

// MARK: - App

@main
struct App: SwiftUI::App {
    var body: some Scene {
        WindowGroup {
            RootScreen<ClipScreen>()
                .rootScreenStyle(.appClip)
        }
    }
}
