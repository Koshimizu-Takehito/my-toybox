import SwiftUI

// MARK: - RootScreen

/// The main entry view that displays a list of available screens
/// in a `NavigationSplitView` layout.
///
/// - On regular width (iPad or landscape), it shows a sidebar and detail panel.
/// - On compact width (iPhone), the detail view appears after selection.
/// - Automatically loads available screen metadata from a local JSON file.
struct RootScreen: View {
    /// The view model that handles fetching available screens.
    @State private var viewModel = RootScreenViewModel()
    /// The currently selected screen from the sidebar.
    @State private var selection: Screen?
    /// The current horizontal size class (e.g., `.compact`, `.regular`).
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @Environment(\.openURL) var openURL

    var body: some View {
        NavigationSplitView(sidebar: sidebarView, detail: detailView)
            .tint(.white)
            .task {
                // Load screens when the view appears.
                await viewModel.fetch()
            }
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

extension RootScreen {
    /// The sidebar view that displays a list of available screens.
    @ViewBuilder
    fileprivate func sidebarView() -> some View {
        List(viewModel.filterdScreens(), selection: $selection) { screen in
            NavigationLink(value: screen) {
                VStack(alignment: .leading) {
                    Text(screen.title)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(screen.description)
                        .font(.subheadline)
                        .foregroundStyle(.foreground.secondary)
                }
                .padding(.bottom)
            }
        }
        .toolbar {
            TagPicker()
        }
#if os(iOS)
        .navigationBarTitle("MyToybox")
        .navigationBarTitleDisplayMode(.inline)
#endif
    }

    /// The detail view that renders the selected screen.
    @ViewBuilder
    fileprivate func detailView() -> some View {
        NavigationStack {
            Group {
                if let selection {
                    // Render the selected screen
                    DetailScreen(id: selection.id)
                } else {
                    Text("Please select a screen")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(selection?.title ?? "")
            .toolbar {
                Button("Sorce Code", systemImage: "safari") {
                    if let url = selection?.html {
                        openURL(url)
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    RootScreen()
}
