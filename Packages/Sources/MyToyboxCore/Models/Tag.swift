import Foundation
import SwiftUI

public enum Tag: String, CaseIterable, Codable, Hashable, Sendable {
    case layout
    case animation
    case metal

    public var color: Color {
        switch self {
        case .layout: .green
        case .animation: .red
        case .metal: .blue
        }
    }
}
