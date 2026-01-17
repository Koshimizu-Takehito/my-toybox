import Foundation

/// Protocol that provides metadata for a screen.
@MainActor
public protocol ScreenMetadata {
    /// The display title of the screen.
    var title: String { get }

    /// A short description of what the screen shows or does.
    var description: String { get }

    /// Tags categorizing this screen.
    var tags: [Tag] { get }
}
