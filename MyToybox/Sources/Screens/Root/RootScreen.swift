import SwiftUI

struct RootScreen: View {
    @State private var viewModel = RootScreenViewModel()
    @State private var selection: Screen?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationSplitView(sidebar: sidebarView, detail: detailView)
            .tint(.white)
            .task {
                await viewModel.fetch()
            }
            .onChange(of: viewModel.screens, initial: true) { _, screens in
                if horizontalSizeClass != .compact {
                    selection = screens.first
                }
            }
            .environment(\.colorScheme, .dark)
    }
}

extension RootScreen {
    @ViewBuilder
    fileprivate func sidebarView() -> some View {
        List(viewModel.screens, selection: $selection) { screen in
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
    }

    @ViewBuilder
    fileprivate func detailView() -> some View {
        NavigationStack {
            Group {
                if let selection {
                    selection
                } else {
                    Text("Please select a screen")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(selection?.title ?? "")
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RootScreen()
}
