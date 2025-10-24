import SwiftUI

struct DetailScreen: View {
    var id: ScreenID

    var body: some View {
        switch id {
        case .strokeModifier:
            StrokeModifierDemoScreen()
        case .metaball2D:
            RandomMetaballDemoScreen()
        case .capsule:
            BadgeDemoScreen()
        case .lissajousCurve1:
            LissajousCurveDemoScreen1()
        case .lissajousCurve2:
            LissajousCurveDemoScreen2()
        case .autoScrolledTextField:
            AutoScrolledTextFieldDemoScreen()
        case .autoScrolledTextField2:
            AutoScrolledTextFieldDemoScreen2()
        case .flipTransition:
            FlipTransitionDemoScreen()
        case .spiralLayout:
            SpiralLayoutDemoScreen()
        case .radialLayout:
            RadialLayoutScreen()
        case .implicitEquation:
            ImplicitEquationScreen()
        case .flowDistortion:
            FlowDistortionScreen()
        case .multiHelix:
            MultiHelixScreen()
        case .pipCard:
            PipCardDemoScreen()
        case .voronoi:
            VoronoiDiagramDemoScreen1()
        case .voronoi2:
            VoronoiDiagramDemoScreen2()
        case .cosmicWeb:
            CosmicWebScreen()
        case .homeIconShakeView:
            HomeIconDemoScreen()
        case .segmentedControl:
            ColorSegmentedControlDemoScreen()
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
        case .shaderKuwahara:
            KuwaharaScreen()
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
        case .visualeffect:
            VisualeffectScreen()
        case .contentTransition:
            ContentTransitionScreen()
        case .flowLayout:
            FlowLayoutScreen()
        case .layoutProtocolSample:
            LayoutProtocolSampleScreen()
        case .scrollRotation:
            ScrollYRotationScreen()
        case .gradientAnimation:
            GradientAnimationScreen()
        case .juliaSet:
            JuliaSetScreen()
        case .squreflow:
            SqureflowScreen()
        case .smoothMin:
            SmoothMinScreen()
        case .loadingAnimation1:
            DotsSpinnerDemoScreen()
        case .loadingAnimation2:
            OrbitingDotsLoaderDemoScreen()
        case .applelogo:
            AppleLogoScreen()
        default:
            EmptyView()
        }
    }
}

#Preview {
    RootScreen()
}
