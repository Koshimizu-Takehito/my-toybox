import SwiftUI

struct ColorSchemeAnimationScreen: View {
    @State private var isDark = false
    @State private var currenct = ColorScheme.light
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Dark Mode", isOn: $isDark)
                    .listRowBackground(rowBackground)
            }
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background)
            .navigationTitle("Color Scheme")
            .environment(\.colorScheme, currenct)
            .preferredColorScheme(currenct)
            .onChange(of: colorScheme, initial: true) { _, value in
                isDark = value == .dark
            }
            .task(id: isDark) {
                try? await Task.sleep(nanoseconds: 1_000_000_00)
                withAnimation(.smooth(duration: 1.0)) {
                    currenct = isDark ? .dark : .light
                }
            }
        }
    }

    private var rowBackground: some View {
        #if os(iOS)
            Color(.secondarySystemGroupedBackground)
        #else
            Color.clear
        #endif
    }

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

#Preview {
    ColorSchemeAnimationScreen()
}
