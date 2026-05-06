import MyToyboxCore
import SwiftUI

extension LissajousCurveDemoScreen1 {
    public static func thumbnail(isScrolling: Bool, time: TimeInterval) -> some View {
        Thumbnail(isScrolling: isScrolling, time: time)
    }

    struct Thumbnail: View {
        @State private var curve = LissajousCurve1()

        var isScrolling: Bool
        var time: TimeInterval

        var body: some View {
            // Calculate elapsed time since animation started, mapped to [0, 2π).
            let time = time
                .truncatingRemainder(dividingBy: 2 * .pi)
            // Update the phase parameter, animating the curve.
            LissajousCurveView1(curve: curve, lineWidth: 2)
                .onChange(of: time, initial: true) { _, newTime in
                    curve.phase = newTime
                }
        }
    }
}

#Preview {
    LissajousCurveDemoScreen1.thumbnail
}
