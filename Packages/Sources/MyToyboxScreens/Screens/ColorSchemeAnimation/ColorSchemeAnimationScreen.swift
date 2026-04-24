import SwiftUI

/// A screen that demonstrates animated transitions between light and dark mode using SwiftUI.
/// Users can toggle dark mode via a switch, and the color scheme changes with a smooth animation.
@Metadata(title: .screenColorSchemeAnimationTitle, description: .screenColorSchemeAnimationDescription, tags: [])
struct ColorSchemeAnimationScreen: View {
    /// Indicates whether dark mode is enabled by the user toggle.
    @State private var isDarkModeOn = false

    /// The current color scheme being applied to the view hierarchy.
    @State private var currentScheme = ColorScheme.light

    /// The system-provided current color scheme.
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            Form {
                Toggle(isOn: $isDarkModeOn) {
                    Text(verbatim: "Dark Mode")
                }
                .listRowBackground(rowBackground)
            }
            .scrollContentBackground(.hidden) // Hides the default form background
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .navigationTitle(Text(verbatim: "Color Scheme"))
            .environment(\.colorScheme, currentScheme) // Updates the environment manually
            .preferredColorScheme(currentScheme) // Also sets it for the current view
            .onChange(of: colorScheme, initial: true) { _, value in
                // Syncs the toggle with the actual system color scheme
                isDarkModeOn = value == .dark
            }
            .task(id: isDarkModeOn) {
                // Adds a slight delay before applying the color scheme change
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                withAnimation(.smooth(duration: 1.0)) {
                    currentScheme = isDarkModeOn ? .dark : .light
                }
            }
        }
    }

    /// Returns an appropriate row background color depending on platform.
    private var rowBackground: some View {
        #if os(iOS)
        Color(.secondarySystemGroupedBackground)
        #else
        Color.clear
        #endif
    }

    /// Returns an appropriate background color depending on platform.
    private var background: some ShapeStyle {
        #if os(iOS)
        Color(.systemGroupedBackground)
        #elseif os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color.clear
        #endif
    }
}

/// SwiftUI preview for the screen.
#Preview {
    ColorSchemeAnimationScreen()
}
