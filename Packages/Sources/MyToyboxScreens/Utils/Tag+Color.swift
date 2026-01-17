import MyToyboxCore
import SwiftUI

public extension Tag {
    var color: Color {
        switch self {
        case .layout: .green
        case .animation: .red
        case .metal: .blue
        }
    }
}
