import SwiftUI

extension EnvironmentValues {
    /// The list style injected into root list views via ``View/rootScreenStyle(_:)``.
    @Entry var rootScreenStyle: RootListStyle = .default
}

public extension View {
    /// Sets the visual style applied to root list views within this view hierarchy.
    func rootScreenStyle(_ style: RootListStyle) -> some View {
        environment(\.rootScreenStyle, style)
    }
}

// MARK: - RootListStyle

/// Visual configuration for the root screen list (background gradient and separator tint).
///
/// Pass a preset or a custom instance via ``View/rootScreenStyle(_:)`` to
/// theme the sidebar/compact list without touching the list implementation.
public struct RootListStyle {
    /// A closure that produces the full-bleed background view drawn behind the list.
    public var background: () -> AnyView

    /// The color applied to list row separators, or `nil` to use the system default.
    public var separatorTint: Color?

    public init(separatorTint: Color? = nil, @ViewBuilder background: @escaping () -> some View = EmptyView.init) {
        self.background = { AnyView(background()) }
        self.separatorTint = separatorTint
    }
}

public extension RootListStyle {
    /// Blue-purple gradient used by the main app.
    static var `default`: Self {
        RootListStyle(separatorTint: .white.opacity(0.2)) {
            LinearGradient(
                colors: [
                    Color(red: 0x77 / 0xFF, green: 0x8C / 0xFF, blue: 0xFF / 0xFF).mix(with: .black, by: 0.15),
                    Color(red: 0x9C / 0xFF, green: 0x00 / 0xFF, blue: 0xD0 / 0xFF).mix(with: .black, by: 0.15),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// Blue-cyan-mint gradient used by the App Clip.
    static var appClip: Self {
        RootListStyle(separatorTint: .white.opacity(0.2)) {
            LinearGradient(
                colors: [
                    .blue.mix(with: .white, by: 0.15).mix(with: .black, by: 0.15),
                    .cyan.mix(with: .black, by: 0.25),
                    .mint.mix(with: .black, by: 0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
