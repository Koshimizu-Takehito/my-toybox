import Observation

/// An observable view‑model that drives a numeric badge.
///
/// `BadgeModel` keeps track of the current count (`number`) and the
/// badge’s visual appearance (`style`)  It also exposes two derived
/// properties that make it easy to bind the model to SwiftUI controls:
///
/// * `slider` – Bridges the `Int`‐based `number` to floating‑point
///   controls such as `Slider`.
/// * `value`  – Returns the string that should actually appear inside
///   the badge. Counts over 999 collapse to `"+999"`; negative values
///   yield `nil`, which you can interpret as “hide the badge.”
@Observable
final class BadgeModel {
    /// The raw count shown on the badge.
    var number: Int

    /// The visual styling applied to the badge.
    var style: BadgeStyle

    /// A proxy that lets `Slider` or other `Double`‑based controls
    /// read and mutate `number` without manual conversions.
    var slider: Double {
        get { Double(number) }
        set { number = Int(newValue) }
    }

    /// The string representation that appears inside the badge, or
    /// `nil` when the badge should be hidden.
    ///
    /// * 0 … 999 → the number itself (`"57"`, `"999"`, …)
    /// * 1000 +  → `"+999"` (caps the visual length)
    /// * < 0     → `nil` (badge off)
    var value: String? {
        switch number {
        case 0 ... 999:
            number.formatted()

        case 1000...:
            "+999"

        default:
            nil
        }
    }

    init(number: Int = 0, style: BadgeStyle = BadgeStyle()) {
        self.number = number
        self.style = style
    }
}
