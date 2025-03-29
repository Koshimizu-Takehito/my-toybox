import SwiftUI
import MapKit

/// A screen that displays a desaturated, monochrome-style map view.
///
/// This view uses a `.saturation` blend mode to suppress map colors
/// by overlaying a transparent rectangle on top of the map content.
/// It's useful for design exploration or focusing on layout contrast.
struct MonotoneMapScreen: View {
    /// The current camera position for the map, centered on Tokyo.
    @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(35.685175, 139.7528),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    var body: some View {
        Map(position: $position)
            .overlay {
                // This overlay desaturates the underlying map using blend mode.
                Rectangle()
                    .ignoresSafeArea()
                    .blendMode(.saturation)
                    .allowsHitTesting(false)
            }
            .compositingGroup() // Ensures blend mode is applied correctly.
            .colorScheme(.light) // Forces light appearance for better contrast.
    }
}

#Preview {
    MonotoneMapScreen()
}
