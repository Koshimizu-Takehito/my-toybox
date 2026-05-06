import MetadatasMacros
import MyToyboxCore
import MyToyboxUI
import ScreenMacros
import SwiftUI

import Screen_CircleSDF2
import Screen_FlowDistortion
import Screen_JuliaSet
import Screen_KuwaharaFilter
import Screen_Mosaic
import Screen_ProgressiveBlur
import Screen_SmoothMin
import Screen_StableFluid
import Screen_VoronoiDiagram

// MARK: - Screen

/// The set of screens available in the App Clip.
///
/// This is a curated subset of the full gallery focused on Metal shader effects,
/// chosen to keep the App Clip binary within the size limit.
/// Each case maps 1-to-1 to a per-screen SPM module imported above.
@Screens
@Metadatas
public enum Screen: String, MyToyboxScreen {
    case stableFluidScreen
    case flowDistortionScreen
    case kuwaharaScreen
    case progressiveBlurScreen
    case mosaicScreen
    case juliaSetScreen
    case smoothMinScreen
    case circleSDF2Screen
    case voronoiDiagramDemoScreen1
    case voronoiDiagramDemoScreen2
}

// MARK: - Preview

#Preview {
    RootScreen<Screen>()
        .rootListStyle(.appClip)
}
