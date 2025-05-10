import Foundation
import SwiftUI

enum Tag: String, CaseIterable, Codable, Hashable {
    case layout
    case animation
    case metal

    var color: Color {
        switch self {
        case .layout: .green
        case .animation: .red
        case .metal: .blue
        }
    }
}
