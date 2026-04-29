import MyToyboxCore
import SwiftUI

// MARK: - RootSidebarView

/// A reusable list view for both split and compact root layouts.
struct RootSidebarView: View {
    /// The screens to display in the sidebar list.
    let screens: [Screen]
    /// Optional selection binding when used in split layout.
    let selection: Binding<Screen?>?
    /// Tracks scroll activity for thumbnail rendering optimization.
    @State private var isScrolling = false

    /// The namespace used for coordinating a navigation transition.
    @Namespace private var namespace

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
            .toolbar {
                TagPicker()
            }
        #if os(iOS)
            .navigationTitle(.appTitle)
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
            }
        } else {
            List(screens, id: \.self) { screen in
                NavigationLink {
                    RootDetailView(selection: screen)
                        .navigationTransition(.zoom(sourceID: screen, in: namespace))
                } label: {
                    RootCell(screen: screen, isScrolling: isScrolling, namespace: namespace)
                }
            }
        }
    }
}
