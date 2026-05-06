import Foundation
import MyToyboxCore
import SwiftUI

nonisolated struct HomeIcon: Hashable, Identifiable {
    var id = UUID()
    var symbol: String
    var color: Color

    init(symbol: String, color: Color) {
        self.symbol = symbol
        self.color = color
    }
}
