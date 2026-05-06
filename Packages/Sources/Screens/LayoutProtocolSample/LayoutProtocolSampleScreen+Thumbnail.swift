import MyToyboxCore
import SwiftUI

public extension LayoutProtocolSampleScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        let column = 3
        let numOfItems = 9
        let numOfVSpace = 2
        let numOfHSpace = 2
        CustomGridLayout(column: column) {
            ForEach(Array(0 ..< numOfItems), id: \.self) { _ in
                Color.cyan
                    .mask { RoundedRectangle(cornerRadius: 1.0) }
                    .layoutValue(key: CustomGridItem.self, value: .cell)
            }
            ForEach(Array(0 ..< numOfVSpace), id: \.self) { _ in
                Color.mint.opacity(0.7)
                    .mask { RoundedRectangle(cornerRadius: 1.0) }
                    .layoutValue(key: CustomGridItem.self, value: .bar(.vertical))
            }
            ForEach(Array(0 ..< numOfHSpace), id: \.self) { _ in
                Color.pink.opacity(0.4)
                    .mask { RoundedRectangle(cornerRadius: 1.0) }
                    .layoutValue(key: CustomGridItem.self, value: .bar(.horizontal))
            }
        }
    }
}

#Preview {
    LayoutProtocolSampleScreen.thumbnail
}
