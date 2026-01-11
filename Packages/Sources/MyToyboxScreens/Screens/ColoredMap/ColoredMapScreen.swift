import MapKit
import SwiftUI

/// A SwiftUI screen that displays a `Map` view with a dynamic color overlay.
///
/// Users can adjust the red, green, and blue components of the overlay color using sliders.
/// The overlay is blended using the `.screen` blend mode to softly tint the map.
struct ColoredMapScreen: View {
    /// The current map camera position, initially centered on Tokyo.
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(35.685175, 139.7528),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    /// The RGB color used for the overlay tint.
    @State private var color = Color.Resolved(red: 0, green: 0, blue: 1)

    var body: some View {
        Map(position: $position)
            .overlay {
                // Overlay a color-tinted transparent rectangle on top of the map.
                Rectangle()
                    .foregroundStyle(Color(color))
                    .ignoresSafeArea()
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .compositingGroup()
            .colorScheme(.light)
            .overlay {
                // Controls for adjusting RGB components of the overlay color.
                VStack {
                    Slider(value: $color.red, in: 0 ... 1)
                    Slider(value: $color.green, in: 0 ... 1)
                    Slider(value: $color.blue, in: 0 ... 1)
                }
                .tint(Color(color)) // Match slider accents to the selected color.
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.bottom)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
            }
    }
}

#Preview {
    ColoredMapScreen()
}
