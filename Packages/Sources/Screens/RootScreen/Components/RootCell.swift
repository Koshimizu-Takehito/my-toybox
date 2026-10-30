import MyToyboxCore
import SwiftUI

// MARK: - RootCell

/// A single row view used by the root screen list.
///
/// Every row shows a leading preview thumbnail. When `namespace` is provided,
/// the thumbnail also acts as the source of the zoom navigation transition.
struct RootCell<Screen: MyToyboxScreen>: View {
    /// The screen metadata source for thumbnail and labels.
    let screen: Screen
    /// Indicates whether the list is actively scrolling.
    let isScrolling: Bool
    /// The namespace used for coordinating a navigation transition.
    var namespace: Namespace.ID?
    /// Baseline row height used for square thumbnail sizing.
    @Environment(\.defaultMinListRowHeight) private var defaultMinListRowHeight

    init(screen: Screen, isScrolling: Bool, namespace: Namespace.ID? = nil) {
        self.screen = screen
        self.isScrolling = isScrolling
        self.namespace = namespace
    }

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
    @ViewBuilder
    var thumbnailView: some View {
        let thumbnail = ZStack {
            Color.clear
            screen.thumbnail
                .environment(\.isScrolling, isScrolling)
        }
        .background(.black.gradient)
        .frame(width: defaultMinListRowHeight, height: defaultMinListRowHeight)
        .clipShape(.rect(cornerRadius: 8))

        if let namespace {
            thumbnail
                .matchedTransitionSource(id: screen, in: namespace)
        } else {
            thumbnail
        }
    }

    var labelView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(screen.title)
                .font(.body)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(screen.description)
                .font(.subheadline)
                .foregroundStyle(.foreground.secondary)
                .lineLimit(2)
        }
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview("Without Transition Source") {
    List {
        RootCell(screen: MockScreen.mockA, isScrolling: false)
    }
    .preferredColorScheme(.dark)
}

#Preview("With Transition Source") {
    struct Container: View {
        @Namespace var namespace
        var body: some View {
            List {
                RootCell(screen: MockScreen.mockA, isScrolling: false, namespace: namespace)
            }
            .preferredColorScheme(.dark)
        }
    }
    return Container()
}
#endif
