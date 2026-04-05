import SwiftUI

extension WaveCircleScreen {
    @ViewBuilder
    static func thumbnail(isScrolling _: Bool, time: TimeInterval) -> some View {
        let offset = Angle.radians(2 * time.truncatingRemainder(dividingBy: 2.0 * .pi))
        GeometryReader { geometry in
            WaveCircleContentView(percent: 0.30, offset: offset, lineWidth: geometry.size.width / 40.0)
                .font(.system(size: geometry.size.width / 10.0).monospacedDigit())
                .bold()
                .fontDesign(.rounded)
                .foregroundStyle(.blue)
                .clipShape(.circle)
                .padding(geometry.size.width / 10.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    WaveCircleScreen.thumbnail
}
