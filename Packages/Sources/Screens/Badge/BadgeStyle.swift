import SwiftUI

struct BadgeStyle: Hashable {
    var font: Font = .largeTitle
    var weight: Font.Weight = .bold
    var tint: Color = .red

    mutating func reset() {
        self = Self()
    }
}
