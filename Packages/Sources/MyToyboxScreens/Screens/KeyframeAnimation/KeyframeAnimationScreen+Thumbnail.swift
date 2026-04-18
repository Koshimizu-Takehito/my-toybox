import SwiftUI

extension KeyframeAnimationScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        Image(systemName: "paperplane.fill")
            .resizable()
            .scaledToFit()
            .padding()
            .foregroundStyle(.orange.gradient)
    }
}

#Preview {
    KeyframeAnimationScreen.thumbnail
}
