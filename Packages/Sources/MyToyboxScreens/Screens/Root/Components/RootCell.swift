import MyToyboxCore
import SwiftUI

// MARK: - RootCell

/// A single row view used by the root screen list.
struct RootCell: View {
    /// The screen metadata source for thumbnail and labels.
    let screen: Screen
    /// Indicates whether the list is actively scrolling.
    let isScrolling: Bool
    /// Baseline row height used for square thumbnail sizing.
    @Environment(\.defaultMinListRowHeight) private var thumbnailSize

    var body: some View {
        HStack(alignment: .top) {
            thumbnailView
            labelView
        }
        .alignmentGuide(.listRowSeparatorLeading) {
            $0[.leading]
        }
    }
}

private extension RootCell {
    var thumbnailView: some View {
        ZStack {
            Color.clear
            screen.thumbnail
                .environment(\.isScrolling, isScrolling)
        }
        .background(.black.gradient)
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(.rect(cornerRadius: 8))
    }

    var labelView: some View {
        VStack(alignment: .leading) {
            Text(screen.title)
                .font(.body)
                .fontWeight(.semibold)
            Text(screen.description)
                .font(.subheadline)
                .foregroundStyle(.foreground.secondary)
        }
    }
}
