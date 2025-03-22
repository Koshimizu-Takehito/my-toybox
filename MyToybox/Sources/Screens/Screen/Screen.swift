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
        case .gradientPolygon:
            GradientPolygonScreen()
        case .collisionColorChange:
            CollisionColorChangeScreen()
        case .solarSystemAnimationView:
            SolarSystem2Screen()
        case .pixelBasedColorToggleView:
            PixelBasedColorChangeScreen()
        case .heliocentricAnimationView:
            SolarSystem1Screen()
        case .countdownAnimation:
            CountdownAnimationScreen()
        default:
            EmptyView()
        }
    }
}
