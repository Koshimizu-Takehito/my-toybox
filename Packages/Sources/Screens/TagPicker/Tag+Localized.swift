import MyToyboxCore
import SwiftUI

extension Tag {
    var localizedTitle: LocalizedStringResource {
        switch self {
        case .layout:
            .tagLayout

        case .animation:
            .tagAnimation

        case .metal:
            .tagMetal
        }
    }
}
