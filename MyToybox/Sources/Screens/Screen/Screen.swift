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
        case .infinitescroll:
            InfiniteScrollScreen()
        case .horizontalPicker:
            HorizontalPickerScreen()
        case .circleSDF1:
            CircleSDF1Screen()
        case .circleSDF2:
            CircleSDF2Screen()
        case .wavingText:
            WavingTextScreen()
        case .coloredMap:
            ColoredMapScreen()
        case .monotoneMap:
            MonotoneMapScreen()
        case .waveParticle:
            WaveParticleScreen()
        case .reverseList:
            ReverseListScreen()
        case .viewIdentity:
            ViewIdentityAnimationScreen()
        case .progressiveblur:
            ProgressiveBlurScreen()
        case .shaderMosaic:
            MosaicScreen()
        case .shaderTile:
            TileShaderScreen()
        case .shaderSpiral:
            SpiralShaderScreen()
        case .primeSpiral:
            PrimeSpiralScreen()
        case .archimedesSpiral:
            ArchimedesSpiralScreen()
        case .motions4:
            Motions4Screen()
        case .matchTopWidth:
            MatchTopWidthScreen()
        default:
            EmptyView()
        }
    }
}
