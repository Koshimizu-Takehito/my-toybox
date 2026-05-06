import SwiftUI

extension EnvironmentValues {
    /// The toolbar content injected into root list views via ``View/rootToolbar(content:)``.
    ///
    /// Defaults to an empty view so callers that omit the modifier produce no toolbar items.
    @Entry var rootToolbar: () -> AnyView = {
        AnyView(EmptyView())
    }
}

public extension View {
    /// Inserts `content` as the toolbar of root list views within this view hierarchy.
    ///
    /// The content is type-erased and forwarded through the environment so
    /// `RootSidebarView` can render it without knowing its concrete type.
    @ViewBuilder
    func rootToolbar(@ViewBuilder content: @escaping () -> some View) -> some View {
        environment(\.rootToolbar) { AnyView(content()) }
    }
}
