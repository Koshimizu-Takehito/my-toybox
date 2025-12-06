import MyToyboxScreens
import SwiftUI

/// The main entry point of the app.
///
/// This struct conforms to the `App` protocol and defines the initial scene of the application.
/// The app launches with the `RootScreen` view displayed in a `WindowGroup`.
@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            // The root view of the application.
            // Replace `RootScreen` with your actual root view implementation.
            RootScreen()
        }
    }
}

// Provides a live preview of the RootScreen for development.
#Preview("RootScreen") {
    RootScreen()
}
