import SwiftUI
import MapKit

struct ColoredMapScreen: View {
    @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(35.685175, 139.7528),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )

    @State var color = Color.Resolved(red: 0, green: 0, blue: 1)

    var body: some View {
        Map(position: $position)
            .overlay {
                Rectangle()
                    .foregroundStyle(Color(color))
                    .ignoresSafeArea()
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
            .compositingGroup()
            .colorScheme(.light)
            .overlay {
                VStack {
                    Slider(value: $color.red, in: 0...1)
                    Slider(value: $color.green, in: 0...1)
                    Slider(value: $color.blue, in: 0...1)
                }
                .tint(Color(color))
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
