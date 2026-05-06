import Foundation
import SwiftUI

/// A category label that classifies screens by technique.
public enum Tag: String, CaseIterable, Codable, Hashable, Sendable {
    case layout
    case animation
    case metal

    /// The SwiftUI color associated with this tag for display in the UI.
    public var color: Color {
        switch self {
        case .layout: .green
        case .animation: .red
        case .metal: .blue
        }
    }
}
