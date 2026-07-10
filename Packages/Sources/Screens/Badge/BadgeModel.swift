import Observation

@Observable
final class BadgeModel {
    var number: Int
    var style: BadgeStyle

    var slider: Double {
        get { Double(number) }
        set { number = Int(newValue) }
    }

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
