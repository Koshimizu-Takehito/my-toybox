import SwiftUI

extension BadgeDemoScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        BadgeView(value: 9)
            .tint(.red)
            .foregroundStyle(.white)
            .transaction { $0.disablesAnimations = true }
    }
}
