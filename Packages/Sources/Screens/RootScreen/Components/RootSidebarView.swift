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
                .listRowSeparatorTint(rootListStyle.separatorTint)
                .listRowBackground(Color.clear)
            }
        } else {
            List(screens, id: \.self) { screen in
                NavigationLink {
                    DetailScreen(screen: screen)
                    #if os(iOS)
                        .navigationTransition(.zoom(sourceID: screen, in: namespace))
                    #endif
                } label: {
                    RootCell(screen: screen, isScrolling: isScrolling, namespace: namespace)
                }
                .listRowSeparatorTint(rootListStyle.separatorTint)
                .listRowBackground(Color.clear)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
import MockScreens

#Preview("Compact") {
    NavigationStack {
        RootSidebarView(screens: MockScreen.allCases)
            .environment(\.rootCellStyle, .previewLeading)
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
