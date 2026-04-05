import SwiftUI

extension DynamicTypeScalingScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        GeometryReader { geometry in
            Image(systemName: "character.cursor.ibeam")
                .resizable()
                .scaledToFit()
                .padding(2 * geometry.size.width / 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.green.gradient)
        }
    }
}

#Preview {
    DynamicTypeScalingScreen.thumbnail
}
