import SwiftUI

/// A configurable style container for badge‑like views.
///
/// `BadgeStyle` groups the three most common visual attributes—`font`,
/// `weight`, and `tint`—into a single value that you can pass around or
/// store. Use it to ensure visual consistency across multiple badges.
struct BadgeStyle: Hashable {
    /// The typeface used for badge text.
    var font: Font = .largeTitle
    /// The font weight applied to the badge text.
    var weight: Font.Weight = .bold
    /// The foreground color of the badge.
    var tint: Color = .red

    /// Restores the style to the built‑in defaults.
    mutating func reset() {
        self = Self()
    }
}
