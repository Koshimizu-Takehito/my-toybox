import Foundation
import SwiftUI

// MARK: - ScreenMetadata

/// Protocol that provides metadata for a screen.
@MainActor
public protocol ScreenMetadata {
    associatedtype ThumbnailContent: View

    /// The display title of the screen.
    var title: LocalizedStringResource { get }

    /// A short description of what the screen shows or does.
    var description: LocalizedStringResource { get }

    /// Tags categorizing this screen.
    var tags: [Tag] { get }

    @ViewBuilder
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> ThumbnailContent
}

public extension ScreenMetadata {
    static var thumbnail: some View {
        ThumbnailView(content: thumbnail(isScrolling:time:))
    }

    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {}
}
