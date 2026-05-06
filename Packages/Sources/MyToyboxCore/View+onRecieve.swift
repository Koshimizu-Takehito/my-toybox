import SwiftUI

// MARK: - View + onRecieve(screen:)

public extension View {
    /// Resolves a `Screen` from an incoming URL and writes it into `screen`.
    ///
    /// Listens for both `onOpenURL` (custom URL scheme / universal link tapped
    /// while the app is foregrounded) and `onContinueUserActivity` with
    /// `NSUserActivityTypeBrowsingWeb` (App Clip invocation via universal link).
    func onRecieve<Screen: MyToyboxScreen>(screen: Binding<Screen?>) -> some View {
        onOpenURL { url in
            screen.wrappedValue = Screen.resolve(from: url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            screen.wrappedValue = activity.webpageURL.flatMap(Screen.resolve(from:))
        }
    }
}
