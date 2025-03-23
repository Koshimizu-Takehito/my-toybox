import SwiftUI
import MapKit

struct MonotoneMapScreen: View {
    @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(35.685175, 139.7528),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    var body: some View {
        Map(position: $position)
            .overlay {
                Rectangle()
                    .ignoresSafeArea()
                    .blendMode(.saturation)
                    .allowsHitTesting(false)
            }
            .compositingGroup()
            .colorScheme(.light)
    }
}

#Preview {
    MonotoneMapScreen()
}
