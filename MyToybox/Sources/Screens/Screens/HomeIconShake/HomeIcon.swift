import Foundation
import SwiftUI

struct HomeIcon: Hashable, Identifiable {
    var id = UUID()
    var symbol: String
    var color: Color

    init(symbol: String, color: Color) {
        self.symbol = symbol
        self.color = color
    }
}
