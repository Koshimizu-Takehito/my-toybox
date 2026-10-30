import Foundation

// MARK: - MyToyboxScreen+ScreenResolver

public extension MyToyboxScreen {
    static func resolve(from url: URL) -> Self? {
        ScreenResolver.screen(from: url)
    }
}

// MARK: - ScreenResolver

/// Resolves `Screen` from incoming URLs (deep-link / App Clip invocation).
enum ScreenResolver<Screen: MyToyboxScreen> {
    /// Resolves a `Screen` from the given URL, or returns `nil`.
    ///
    /// Query (`?screen=<id>`) takes priority over path (`/my-toybox-clip/<id>`).
    static func screen(from url: URL) -> Screen? {
        screenFromQuery(url) ?? screenFromPath(url)
    }

    private static func screenFromQuery(_ url: URL) -> Screen? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "screen" }?
            .value
            .flatMap(Screen.init(rawValue:))
    }

    private static func screenFromPath(_ url: URL) -> Screen? {
        let pattern = /\/my-toybox-clip\/([^\/]+)\/?/
        return url.path()
            .wholeMatch(of: pattern)
            .flatMap { Screen(rawValue: String($0.1)) }
    }
}
