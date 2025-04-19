import SwiftUI

/// A model representing a single screen that can be displayed in the app.
///
/// This structure conforms to `Identifiable`, `Codable`, and `Hashable`,
/// making it suitable for use in SwiftUI lists, decoding from JSON, and performing set operations.
///
/// This model is typically populated by reading from a bundled JSON file (e.g., `Screens.json`).
struct Screen: Identifiable, Codable, Hashable {
    /// A unique identifier for the screen.
    var id: ScreenID

    /// The display title of the screen.
    var title: String

    /// A short description of what the screen shows or does.
    var description: String

    /// A URL pointing to an associated HTML documentation file.
    /// This might be used for external links.
    var html: URL
}
