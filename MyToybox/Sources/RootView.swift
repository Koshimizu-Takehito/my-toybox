import SwiftUI

struct RootView: View {
    @State private var selectedScreen: Screen?

    var body: some View {
        NavigationSplitView(sidebar: sidebarView, detail: detailView)
    }
}

private extension RootView {
    @ViewBuilder
    func sidebarView() -> some View {
        List(Screen.allCases, selection: $selectedScreen) { screen in
            NavigationLink(value: screen) {
                Text(screen.displayTitle)
            }
        }
    }

    @ViewBuilder
    func detailView() -> some View {
        if let screen = selectedScreen {
            screen
        } else {
            Text("Please select a screen")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootView()
}
