import SwiftUI

/// A model representing a single screen that can be displayed in the app.
///
/// This structure conforms to `Identifiable`, `Codable`, and `Hashable`,
/// making it suitable for use in SwiftUI lists, decoding from JSON, and performing set operations.
///
/// This model is typically populated by reading from a bundled JSON file (e.g., `Screens.json`).
struct Screen: Identifiable, Codable, Hashable {
    /// A unique identifier for the screen.
    var id: ScreenID

    /// The display title of the screen.
    var title: String

    /// A short description of what the screen shows or does.
    var description: String

    /// A URL pointing to an associated HTML documentation file.
    /// This might be used for external links.
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
        case .authCode:
            AuthCodeScreen()
        case .tileAnimation:
            TileAnimationScreen()
        case .tileAnimation3D:
            TileAnimation3DScreen()
        case .shineShader:
            ShineScreen()
        case .waveCircle:
            WaveCircleScreen()
        case .rectangleAnimation:
            RectangleAnimationScreen()
        case .dateformatstyle:
            DateformatStyleScreen()
        case .scaledmetric:
            DynamicTypeScalingScreen()
        case .dynamictype:
            DynamicTypeScreen()
        case .colorSchemeAnimation:
            ColorSchemeAnimationScreen()
        case .uiviewcontrollerrepresentable:
            ViewcontrollerRepresentableScreen()
        case .enumpicker:
            EnumPickerScreen()
        case .ringSlider:
            RingSliderScreen()
        case .unevenRoundedRectang1:
            UnevenRoundedRectangle1Screen()
        case .unevenRoundedRectang2:
            UnevenRoundedRectangle2Screen()
        case .colorHexAnimation:
            ColorHexAnimationScreen()
        case .ringanimation:
            RinganimationScreen()
        case .progressring:
            ProgressRingScreen()
        case .lostRowAnimation:
            LostRowAnimationScreen()
        case .hierarchicalShapeStyle:
            HierarchicalShapeStyleScreen()
        case .mazeGenerator:
            MazeGeneratorScreen()
        case .meshgradient:
            Meshgradient2Screen()
        default:
            EmptyView()
        }
    }
}
