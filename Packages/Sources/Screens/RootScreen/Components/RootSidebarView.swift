import DetailScreen
import MyToyboxCore
import SwiftUI

// MARK: - RootSidebarView

/// A reusable list view for both split and compact root layouts.
struct RootSidebarView<Screen: MyToyboxScreen>: View {
    /// The screens to display in the sidebar list.
    let screens: [Screen]
    /// Optional selection binding when used in split layout.
    let selection: Binding<Screen?>?
    /// Tracks scroll activity for thumbnail rendering optimization.
    @State private var isScrolling = false

    /// The namespace used for coordinating a navigation transition.
    @Namespace private var namespace

    @Environment(\.rootToolbar) private var rootToolbar
    @Environment(\.rootScreenStyle) private var rootListStyle

    init(screens: [Screen], selection: Binding<Screen?>? = nil) {
        self.screens = screens
        self.selection = selection
    }

    var body: some View {
        listView
            .onScrollPhaseChange { _, newPhase in
                isScrolling = newPhase.isScrolling
            }
            .listStyle(.plain)
            .toolbar { rootToolbar }
        #if os(iOS)
            .scrollContentBackground(.hidden)
            .background {
                rootListStyle.background()
                    .ignoresSafeArea()
            }
            .navigationTitle(Text("app.title", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private extension RootSidebarView {
    @ViewBuilder
    var listView: some View {
        if let selection {
            List(screens, id: \.self, selection: selection) { screen in
                NavigationLink(value: screen) {
                    RootCell(screen: screen, isScrolling: isScrolling)
                }
                // The rounded selection highlight separates rows, like a system sidebar.
                .listRowSeparator(.hidden)
                .listRowBackground(rowBackground(isSelected: screen == selection.wrappedValue))
            }
        } else {
            List(screens, id: \.self) { screen in
                NavigationLink(value: screen) {
                    RootCell(screen: screen, isScrolling: isScrolling, namespace: namespace)
                }
                .listRowSeparatorTint(rootListStyle.separatorTint)
                .listRowBackground(Color.clear)
            }
            .navigationDestination(for: Screen.self) { screen in
                DetailScreen(screen: screen)
                #if os(iOS)
                    .navigationTransition(.zoom(sourceID: screen, in: namespace))
                #endif
            }
        }
    }

    /// A rounded highlight drawn behind the selected row in split layout.
    func rowBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(rootListStyle.selectionTint)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .opacity(isSelected ? 1 : 0)
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview("Compact") {
    NavigationStack {
        RootSidebarView(screens: MockScreen.allCases)
            .preferredColorScheme(.dark)
    }
}

#Preview("Split") {
    @Previewable @State var selection: MockScreen? = .mockA
    NavigationStack {
        RootSidebarView(screens: MockScreen.allCases, selection: $selection)
            .preferredColorScheme(.dark)
    }
}
#endif
