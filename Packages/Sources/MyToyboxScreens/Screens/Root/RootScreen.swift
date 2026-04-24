import MyToyboxCore
import SwiftUI

// MARK: - RootScreen

/// The main entry view that displays a list of available screens
/// in a `NavigationSplitView` layout.
///
/// - On regular width (iPad or landscape), it shows a sidebar and detail panel.
/// - On compact width (iPhone), the detail view appears after selection.
/// - Automatically loads available screens from the `Screen` enum.
public struct RootScreen: View {
    /// The view model that handles fetching available screens.
    @State private var viewModel = RootViewModel()
    /// The currently selected screen from the sidebar.
    @State private var selection: Screen?
    /// The current horizontal size class (e.g., `.compact`, `.regular`).
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @Environment(\.defaultMinListRowHeight) var thumbnailSize

    @Environment(\.openURL) var openURL

    @State private var isScrolling: Bool = false

    public init() {}

    public var body: some View {
        NavigationSplitView(sidebar: sidebarView, detail: detailView)
            .tint(.white)
            .onChange(of: viewModel.screens, initial: true) { _, screens in
                // Preselect the first screen if not in compact mode (e.g., iPad).
                if horizontalSizeClass != .compact {
                    selection = screens.first
                }
            }
            // Force dark mode appearance 😎
            .preferredColorScheme(.dark)
            .environment(viewModel.tags)
    }
}

private extension RootScreen {
    /// The sidebar view that displays a list of available screens.
    @ViewBuilder
    func sidebarView() -> some View {
        List(viewModel.filteredScreens(), id: \.self, selection: $selection) { screen in
            NavigationLink(value: screen) {
                cell(screen: screen)
            }
        }
        .onScrollPhaseChange { _, newPhase in
            isScrolling = newPhase.isScrolling
        }
        .listStyle(.plain)
        .toolbar {
            TagPicker()
        }
        #if os(iOS)
        .navigationTitle(.appTitle)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @ViewBuilder
    func cell(screen: Screen) -> some View {
        HStack(alignment: .top) {
            thumbnail(screen: screen)
            label(screen: screen)
        }
        .alignmentGuide(.listRowSeparatorLeading) {
            $0[.leading]
        }
    }

    @ViewBuilder
    func thumbnail(screen: Screen) -> some View {
        ZStack {
            Color.clear
            screen.thumbnail
                .environment(\.isScrolling, isScrolling)
        }
        .background(.black.gradient)
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(.rect(cornerRadius: 8))
    }

    @ViewBuilder
    func label(screen: Screen) -> some View {
        VStack(alignment: .leading) {
            Text(screen.title)
                .font(.body)
                .fontWeight(.semibold)
            Text(screen.description)
                .font(.subheadline)
                .foregroundStyle(.foreground.secondary)
        }
    }

    /// The detail view that renders the selected screen.
    @ViewBuilder
    func detailView() -> some View {
        NavigationStack {
            Group {
                if let selection {
                    // Render the selected screen
                    selection
                } else {
                    Text(.appSelectScreen)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(selection?.title ?? .appTitle)
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RootScreen()
}
