import SpriteKit
import SwiftUI

#if os(iOS)

extension PhysicsTagScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> Thumbnail {
        Thumbnail()
    }

    struct Thumbnail: View {
        @State private var scene: PhysicsTagThumbnailScene = {
            let scene = PhysicsTagThumbnailScene()
            scene.scaleMode = .resizeFill
            return scene
        }()

        var body: some View {
            SpriteView(scene: scene)
                .accessibilityHidden(true)
        }
    }
}

#else

extension PhysicsTagScreen {
    static func thumbnail(isScrolling _: Bool, time _: TimeInterval) -> some View {
        EmptyView()
    }
}

#endif

#if os(iOS)
#Preview {
    PhysicsTagScreen.thumbnail
        .frame(width: 52, height: 52)
        .clipShape(.rect(cornerRadius: 8))
        .preferredColorScheme(.dark)
}
#endif
