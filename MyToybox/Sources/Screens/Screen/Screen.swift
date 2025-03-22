import SwiftUI

struct Screen: Identifiable, Codable, Hashable {
    var id: ScreenID
    var title: String
    var description: String
    var html: URL
}

extension Screen: View {
    var body: some View {
        switch id {
        case .collisionColorChange:
            CollisionColorChangeScreen()
        default:
            EmptyView()
        }
    }
}
