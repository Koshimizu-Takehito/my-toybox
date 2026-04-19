import SwiftUI

extension LissajousCurveDemoScreen2 {
    static func thumbnail(isScrolling: Bool, time: TimeInterval) -> Thumbnail {
        Thumbnail(isScrolling: isScrolling, time: time)
    }

    struct Thumbnail: View {
        @State private var curve = LissajousCurve2()
        var isScrolling: Bool
        var time: TimeInterval

        var body: some View {
            LissajousCurveView2(curve: curve, lineWidth: 2)
                .onChange(of: time) { _, time in
                    curve.l = 3 + 2 * CGFloat(1 + sin(time.truncatingRemainder(dividingBy: 2 * .pi)))
                }
                .onAppear {
                    curve.k = 2
                }
        }
    }
}

#Preview {
    LissajousCurveDemoScreen2.thumbnail
}
