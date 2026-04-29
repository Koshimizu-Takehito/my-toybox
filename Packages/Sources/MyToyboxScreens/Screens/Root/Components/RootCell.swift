import MyToyboxCore
import SwiftUI

// MARK: - RootCellStyle

/// Visual variants for a root list row.
///
/// The style controls whether the cell shows a leading preview thumbnail
/// or renders as text-only.
enum RootCellStyle {
    /// Text-focused row style without a leading preview.
    case textOnly
    /// Row style that shows a leading preview thumbnail.
    case previewLeading

    /// Returns whether the style renders a leading preview.
    var showsLeadingPreview: Bool {
        switch self {
        case .textOnly:
            false
        case .previewLeading:
            true
        }
    }
}

/// Environment value used by `RootCell` to resolve its visual style.
extension EnvironmentValues {
    /// The current style applied to root list cells.
    @Entry var rootCellStyle: RootCellStyle = .textOnly
}

// MARK: - RootCell

/// A single row view used by the root screen list.
struct RootCell: View {
    /// The screen metadata source for thumbnail and labels.
    let screen: Screen
    /// Indicates whether the list is actively scrolling.
    let isScrolling: Bool
    /// The namespace used for coordinating a navigation transition.
    var namespace: Namespace.ID? = nil
    /// Baseline row height used for square thumbnail sizing.
    @Environment(\.defaultMinListRowHeight) private var defaultMinListRowHeight
    /// The style context that controls whether a leading preview is shown.
    @Environment(\.rootCellStyle) private var style

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
        if style.showsLeadingPreview, let namespace {
            ZStack {
                Color.clear
                screen.thumbnail
                    .environment(\.isScrolling, isScrolling)
            }
            .background(.black.gradient)
            .frame(width: defaultMinListRowHeight, height: defaultMinListRowHeight)
            .clipShape(.rect(cornerRadius: 8))
            .matchedTransitionSource(id: screen, in: namespace)
        }
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
