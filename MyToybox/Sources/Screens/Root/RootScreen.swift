import SwiftUI

struct RootScreen: View {
    @State private var selection: Screen?
    @State private var viewModel = RootScreenModel()

    var body: some View {
        NavigationSplitView(sidebar: sidebarView, detail: detailView)
            .task { await viewModel.fetch() }
            .preferredColorScheme(.dark)
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
